const http = require('http');
const fs = require('fs');
const path = require('path');

loadEnv();

const PORT = Number(process.env.PORT || 3027);
const USERNAME = process.env.DEMO_USERNAME || 'linjiaqi';
const PASSWORD = process.env.DEMO_PASSWORD || '123456';
const DOOR_SECURITY_PIN = process.env.DOOR_SECURITY_PIN || '123456';
const DOOR_REQUIRE_PIN = process.env.DOOR_REQUIRE_PIN === 'true';
const AI_API_KEY = process.env.AI_API_KEY || '';
const AI_BASE_URL = process.env.AI_BASE_URL || 'https://api.openai.com/v1/chat/completions';
const AI_MODEL = process.env.AI_MODEL || 'gpt-4.1-mini';
const DOOR_OPEN_DELAY_MS = 3000;
const DOOR_AUTO_LOCK_MS = 10000;
const DOOR_PIN_LOCK_MS = 60000;
const PUBLIC_ROOT = path.join(__dirname, 'public');
const UPLOADS_ROOT = path.join(__dirname, 'uploads');
const MUSIC_ROOT = path.join(__dirname, 'public', 'music');
const BUILTIN_DEMO_TRACK = {
  id: 'demo-tone',
  title: '智能音箱演示音乐',
  artist: '鸿居智控',
  url: '/music/demo-tone.wav'
};

ensureDemoMusicFile();

const defaultAdminRooms = [
  {
    id: 'living',
    name: '客厅',
    devices: [
      { id: 'living_light', type: 'light', name: '客厅灯光', power: false },
      { id: 'living_air', type: 'air', name: '客厅空调', power: true, temperature: 26, mode: '制冷' },
      { id: 'living_curtain', type: 'curtain', name: '客厅窗帘', power: true, brightness: 60, mode: '自动' },
      { id: 'living_tv', type: 'tv', name: '客厅电视', power: false },
      { id: 'living_speaker', type: 'speaker', name: '客厅智能音箱', power: true, listening: true, lastBroadcast: '全屋设备在线', musicTrackId: getPreferredMusicTrack().id, musicTitle: getPreferredMusicTrack().title, musicUrl: getPreferredMusicTrack().url, musicPlaying: false },
      { id: 'living_robot', type: 'robot', name: '客厅扫地机器人', power: false, cleanMode: 'auto', activityArea: '客厅', battery: 86, cleaningProgress: 0 }
    ]
  },
  {
    id: 'bedroom',
    name: '卧室',
    devices: [
      { id: 'bedroom_light', type: 'light', name: '卧室灯光', power: true },
      { id: 'bedroom_air', type: 'air', name: '卧室空调', power: false, temperature: 24, mode: '睡眠' },
      { id: 'bedroom_curtain', type: 'curtain', name: '卧室窗帘', power: true, brightness: 60, mode: '自动' },
      { id: 'entrance_door', type: 'door', name: '入户门禁', power: false, locked: true }
    ]
  }
];

let dbPool = null;
let dbMode = 'memory';
const memoryStore = {
  users: [
    { id: 1, username: USERNAME, password_plain: PASSWORD, role: 'linjiaqi' }
  ],
  roomsByUsername: {
    [USERNAME]: clone(defaultAdminRooms)
  },
  logsByUsername: {
    [USERNAME]: []
  },
  doorSecurityByUsername: {
    [USERNAME]: {}
  },
  sceneConfigByUsername: {
    [USERNAME]: {
      homeTypes: ['light', 'air'],
      awayTypes: ['door'],
      sleepTypes: ['light', 'air', 'door'],
      energyTypes: ['air']
    }
  },
  currentModeByUsername: {
    [USERNAME]: 'home'
  },
  environmentByUsername: {
    [USERNAME]: {
      roomName: '客厅',
      temperature: 26,
      humidity: 48
    }
  },
  utilityByUsername: {
    [USERNAME]: {
      electricBalance: 128.5,
      gasBalance: 86.2,
      waterBalance: 64.8
    }
  },
  familyMembersByUsername: {
    [USERNAME]: []
  },
  doorCameraByUsername: {
    [USERNAME]: {}
  },
  nextRoomId: 1,
  nextDeviceId: 1,
  nextLogId: 1,
  nextFamilyId: 1
};
const doorAutomationTimers = new Map();
const ROBOT_PROGRESS_INTERVAL_MS = 1000;
const ROBOT_PROGRESS_STEP = 4;

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function averageBrightness(lights) {
  if (!lights.length) {
    return 0;
  }
  const total = lights.reduce((sum, item) => sum + (item.brightness || 0), 0);
  return Math.round(total / lights.length);
}

function defaultEnvironmentConfig() {
  return {
    roomName: '客厅',
    temperature: 26,
    humidity: 48
  };
}

function buildEnvironmentMetrics(rooms, configuredEnvironment) {
  if (configuredEnvironment) {
    return {
      roomName: configuredEnvironment.roomName || '',
      temperature: typeof configuredEnvironment.temperature === 'number' ? configuredEnvironment.temperature : 26,
      humidity: typeof configuredEnvironment.humidity === 'number' ? configuredEnvironment.humidity : 48
    };
  }

  const roomsWithLights = rooms.filter((room) => room.devices.some((device) => device.type === 'light'));
  const candidateRooms = roomsWithLights.length > 0 ? roomsWithLights : rooms;
  const targetRoom = candidateRooms[0];
  if (!targetRoom) {
    return defaultEnvironmentConfig();
  }

  const lights = targetRoom.devices.filter((device) => device.type === 'light');
  const air = targetRoom.devices.find((device) => device.type === 'air');
  const avg = averageBrightness(lights);
  const temperature = air && air.power
    ? clamp((air.temperature || 26) - avg / 45, 18, 30)
    : clamp(26 + (100 - avg) / 80, 20, 31);
  const humidity = clamp(54 - avg / 6, 32, 65);

  return {
    roomName: targetRoom.name,
      temperature: Number(temperature.toFixed(1)),
      humidity: Number(humidity.toFixed(0))
  };
}

function loadEnv() {
  const envPath = path.join(__dirname, '.env');
  if (!fs.existsSync(envPath)) {
    return;
  }

  const lines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/);
  lines.forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) {
      return;
    }
    const splitIndex = trimmed.indexOf('=');
    if (splitIndex < 0) {
      return;
    }
    const key = trimmed.slice(0, splitIndex).trim();
    const value = trimmed.slice(splitIndex + 1).trim();
    if (!process.env[key]) {
      process.env[key] = value;
    }
  });
}

function clone(data) {
  return JSON.parse(JSON.stringify(data));
}

function now() {
  return new Date().toISOString();
}

function toMysqlDate(isoTime) {
  return isoTime.slice(0, 19).replace('T', ' ');
}

function boolToTinyInt(value) {
  return value ? 1 : 0;
}

function tinyIntToBool(value) {
  return value === 1 || value === true;
}

function normalizeMediaUrl(rawUrl) {
  const value = `${rawUrl || ''}`.trim();
  if (!value) {
    return '';
  }
  if (value.startsWith('http://') || value.startsWith('https://') || value.startsWith('/')) {
    return value;
  }
  return `/${value.replace(/^\/+/, '')}`;
}

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function writeUInt32LE(buffer, value, offset) {
  buffer[offset] = value & 0xff;
  buffer[offset + 1] = (value >> 8) & 0xff;
  buffer[offset + 2] = (value >> 16) & 0xff;
  buffer[offset + 3] = (value >> 24) & 0xff;
}

function writeUInt16LE(buffer, value, offset) {
  buffer[offset] = value & 0xff;
  buffer[offset + 1] = (value >> 8) & 0xff;
}

function ensureDemoMusicFile() {
  ensureDir(MUSIC_ROOT);
  const filePath = path.join(MUSIC_ROOT, 'demo-tone.wav');
  if (fs.existsSync(filePath)) {
    return;
  }

  const sampleRate = 44100;
  const durationSec = 4;
  const samples = sampleRate * durationSec;
  const dataSize = samples * 2;
  const buffer = Buffer.alloc(44 + dataSize);
  buffer.write('RIFF', 0);
  writeUInt32LE(buffer, 36 + dataSize, 4);
  buffer.write('WAVE', 8);
  buffer.write('fmt ', 12);
  writeUInt32LE(buffer, 16, 16);
  writeUInt16LE(buffer, 1, 20);
  writeUInt16LE(buffer, 1, 22);
  writeUInt32LE(buffer, sampleRate, 24);
  writeUInt32LE(buffer, sampleRate * 2, 28);
  writeUInt16LE(buffer, 2, 32);
  writeUInt16LE(buffer, 16, 34);
  buffer.write('data', 36);
  writeUInt32LE(buffer, dataSize, 40);

  for (let i = 0; i < samples; i += 1) {
    const t = i / sampleRate;
    const envelope = Math.min(1, i / 4000, (samples - i) / 4000);
    const tone = Math.sin(2 * Math.PI * 392 * t) * 0.45 + Math.sin(2 * Math.PI * 523.25 * t) * 0.25;
    const value = Math.round(clamp(tone * envelope, -1, 1) * 32767);
    buffer.writeInt16LE(value, 44 + i * 2);
  }

  fs.writeFileSync(filePath, buffer);
}

function slugifyMusicId(fileName) {
  const baseName = path.parse(fileName).name;
  const ascii = baseName
    .toLowerCase()
    .replace(/[^a-z0-9\u4e00-\u9fa5]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return ascii || `track-${Date.now()}`;
}

function buildMusicTrackFromFile(fileName) {
  return {
    id: slugifyMusicId(fileName),
    title: path.parse(fileName).name,
    artist: '本地导入',
    url: `/music/${encodeURIComponent(fileName)}`
  };
}

function getMusicLibrary() {
  ensureDir(MUSIC_ROOT);
  const files = fs.readdirSync(MUSIC_ROOT, { withFileTypes: true })
    .filter((item) => item.isFile())
    .map((item) => item.name)
    .filter((name) => ['.mp3', '.wav', '.ogg'].includes(path.extname(name).toLowerCase()));
  const tracks = files.map(buildMusicTrackFromFile);
  if (!tracks.some((item) => item.id === BUILTIN_DEMO_TRACK.id)) {
    tracks.unshift(BUILTIN_DEMO_TRACK);
  }
  return tracks;
}

function getPreferredMusicTrack() {
  const tracks = getMusicLibrary();
  const bubbleTrack = tracks.find((item) => item.title.includes('泡沫'));
  return bubbleTrack || tracks[0] || BUILTIN_DEMO_TRACK;
}

function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === '.mp4') {
    return 'video/mp4';
  }
  if (ext === '.webm') {
    return 'video/webm';
  }
  if (ext === '.mp3') {
    return 'audio/mpeg';
  }
  if (ext === '.wav') {
    return 'audio/wav';
  }
  if (ext === '.ogg') {
    return 'audio/ogg';
  }
  if (ext === '.mov') {
    return 'video/quicktime';
  }
  if (ext === '.png') {
    return 'image/png';
  }
  if (ext === '.jpg' || ext === '.jpeg') {
    return 'image/jpeg';
  }
  if (ext === '.gif') {
    return 'image/gif';
  }
  if (ext === '.webp') {
    return 'image/webp';
  }
  if (ext === '.css') {
    return 'text/css; charset=utf-8';
  }
  if (ext === '.js' || ext === '.mjs') {
    return 'text/javascript; charset=utf-8';
  }
  if (ext === '.json') {
    return 'application/json; charset=utf-8';
  }
  return 'application/octet-stream';
}

function mysqlConfigReady() {
  return process.env.DB_ENABLED === 'true' || Boolean(process.env.MYSQL_HOST);
}

function normalizeRoomName(name) {
  const value = `${name || ''}`.trim();
  const lower = value.toLowerCase();

  if (!value) {
    return '';
  }
  if (lower === 'zhuwo' || value.includes('\u4e3b\u5367')) {
    return '\u4e3b\u5367';
  }
  if (lower === 'ciwo' || value.includes('\u6b21\u5367')) {
    return '\u6b21\u5367';
  }
  if (lower === 'woshi' || value.includes('\u5367\u5ba4')) {
    return '\u5367\u5ba4';
  }
  if (lower === 'keting' || value.includes('\u5ba2\u5385')) {
    return '\u5ba2\u5385';
  }
  if (lower === 'canting' || value.includes('\u9910\u5385')) {
    return '\u9910\u5385';
  }
  if (lower === 'chufang' || value.includes('\u53a8\u623f')) {
    return '\u53a8\u623f';
  }
  if (lower === 'weishengjian' || value.includes('\u536b\u751f\u95f4') || value.includes('\u6d74\u5ba4')) {
    return '\u536b\u751f\u95f4';
  }
  if (lower === 'shufang' || value.includes('\u4e66\u623f')) {
    return '\u4e66\u623f';
  }
  return value;
}

function isSameRoomName(left, right) {
  return normalizeRoomName(left) === normalizeRoomName(right);
}

function defaultVisitorState() {
  return {
    visitorType: 'delivery',
    visitorName: '快递员',
    riskLevel: 'low',
    visitorVerified: false,
    cameraStatus: 'active'
  };
}

function visitorPreset(type) {
  if (type === 'family') {
    return {
      visitorType: 'family',
      visitorName: '家人',
      riskLevel: 'low',
      visitorVerified: true,
      cameraStatus: 'active'
    };
  }
  if (type === 'takeaway') {
    return {
      visitorType: 'takeaway',
      visitorName: 'takeaway',
      riskLevel: 'medium',
      visitorVerified: false,
      cameraStatus: 'active'
    };
  }
  if (type === 'stranger') {
    return {
      visitorType: 'stranger',
      visitorName: '陌生访客',
      riskLevel: 'high',
      visitorVerified: false,
      cameraStatus: 'alert'
    };
  }
  if (type === 'none') {
    return {
      visitorType: 'none',
      visitorName: '无人',
      riskLevel: 'low',
      visitorVerified: false,
      cameraStatus: 'idle'
    };
  }
  return defaultVisitorState();
}

function defaultDoorSecurity(device) {
  const visitor = defaultVisitorState();
  return {
    lockStatus: device.locked === false ? 'unlocked' : 'locked',
    doorStatus: 'closed',
    cameraStatus: visitor.cameraStatus,
    visitorType: visitor.visitorType,
    visitorName: visitor.visitorName,
    riskLevel: visitor.riskLevel,
    visitorVerified: visitor.visitorVerified,
    failedAttempts: 0,
    lockUntil: null,
    lastUnlockTime: null
  };
}

function mergeDoorSecurity(device, security) {
  const fallback = defaultDoorSecurity(device);
  const resolved = Object.assign({}, fallback, security || {});
  return {
    id: device.id,
    type: device.type,
    name: device.name,
    power: resolved.lockStatus === 'unlocked',
    locked: resolved.lockStatus !== 'unlocked',
    brightness: device.brightness,
    temperature: device.temperature,
    mode: device.mode,
    lockStatus: resolved.lockStatus,
    doorStatus: resolved.doorStatus,
    cameraStatus: resolved.cameraStatus,
    visitorType: resolved.visitorType,
    visitorName: resolved.visitorName,
    riskLevel: resolved.riskLevel,
    visitorVerified: resolved.visitorVerified,
    failedAttempts: resolved.failedAttempts,
    lockUntil: resolved.lockUntil,
    lastUnlockTime: resolved.lastUnlockTime
  };
}

function clearDoorAutomation(deviceId) {
  const timers = doorAutomationTimers.get(deviceId);
  if (!timers) {
    return;
  }
  if (timers.openTimer) {
    clearTimeout(timers.openTimer);
  }
  if (timers.relockTimer) {
    clearTimeout(timers.relockTimer);
  }
  doorAutomationTimers.delete(deviceId);
}

function buildHomeName(username) {
  return `${username}的家`;
}

function defaultUtilityAccount() {
  return {
    electricBalance: 128.5,
    gasBalance: 86.2,
    waterBalance: 64.8
  };
}

function defaultSceneConfig() {
  return {
    home: { key: 'home', label: '回家模式', builtIn: true, devices: [] },
    away: { key: 'away', label: '离家模式', builtIn: true, devices: [] },
    sleep: { key: 'sleep', label: '睡眠模式', builtIn: true, devices: [] },
    energy: { key: 'energy', label: '节能模式', builtIn: true, devices: [] },
    customModes: []
  };
}

function defaultSceneDevicePreset(deviceId, deviceType, deviceName, roomName, enabled, brightness, temperature, mode, locked) {
  return {
    deviceId,
    deviceType,
    deviceName,
    roomName,
    enabled: enabled === true,
    brightness,
    temperature,
    mode,
    locked
  };
}

function sceneModeMeta(modeKey) {
  if (modeKey === 'home') {
    return { key: 'home', label: '回家模式', builtIn: true };
  }
  if (modeKey === 'away') {
    return { key: 'away', label: '离家模式', builtIn: true };
  }
  if (modeKey === 'sleep') {
    return { key: 'sleep', label: '睡眠模式', builtIn: true };
  }
  if (modeKey === 'energy') {
    return { key: 'energy', label: '节能模式', builtIn: true };
  }
  return { key: modeKey, label: 'custom_scene', builtIn: false };
}

function defaultSceneDeviceValues(modeKey, deviceType) {
  if (modeKey === 'home') {
    if (deviceType === 'light') {
      return { enabled: true, brightness: 72 };
    }
    if (deviceType === 'curtain') {
      return { enabled: true, brightness: 100, mode: '自动' };
    }
    if (deviceType === 'air') {
      return { enabled: true, temperature: 24, mode: '制冷' };
    }
    if (deviceType === 'door') {
      return { enabled: true, locked: true };
    }
  } else if (modeKey === 'away') {
    if (deviceType === 'light') {
      return { enabled: false, brightness: 0 };
    }
    if (deviceType === 'curtain') {
      return { enabled: true, brightness: 0, mode: '手动' };
    }
    if (deviceType === 'air') {
      return { enabled: false, temperature: 26, mode: '制冷' };
    }
    if (deviceType === 'door') {
      return { enabled: true, locked: true };
    }
  } else if (modeKey === 'sleep') {
    if (deviceType === 'light') {
      return { enabled: true, brightness: 20 };
    }
    if (deviceType === 'curtain') {
      return { enabled: true, brightness: 0, mode: '睡眠' };
    }
    if (deviceType === 'air') {
      return { enabled: true, temperature: 26, mode: '睡眠' };
    }
    if (deviceType === 'door') {
      return { enabled: true, locked: true };
    }
  } else if (modeKey === 'energy') {
    if (deviceType === 'light') {
      return { enabled: true, brightness: 35 };
    }
    if (deviceType === 'curtain') {
      return { enabled: true, brightness: 40, mode: '节能' };
    }
    if (deviceType === 'air') {
      return { enabled: true, temperature: 27, mode: '节能' };
    }
    if (deviceType === 'door') {
      return { enabled: true, locked: true };
    }
  }
  if (deviceType === 'door') {
    return { enabled: true, locked: true };
  }
  if (deviceType === 'curtain') {
    return { enabled: true, brightness: 60, mode: '自动' };
  }
  return { enabled: false };
}

function buildSceneModeFromRooms(modeKey, label, rooms, builtIn) {
  const devices = [];
  for (const room of rooms) {
    for (const device of room.devices) {
      const type = normalizeType(device.type);
      if (!['light', 'curtain', 'air', 'door'].includes(type)) {
        continue;
      }
      const defaults = defaultSceneDeviceValues(modeKey, type);
      devices.push(defaultSceneDevicePreset(
        device.id,
        type,
        device.name,
        room.name,
        defaults.enabled,
        defaults.brightness,
        defaults.temperature,
        defaults.mode,
        defaults.locked
      ));
    }
  }
  return {
    key: modeKey,
    label,
    builtIn: builtIn === true,
    devices
  };
}

function normalizeSceneDevicePreset(raw, fallback) {
  const merged = Object.assign({}, fallback || {}, raw || {});
  const type = normalizeType(merged.deviceType || (fallback ? fallback.deviceType : 'other'));
  const brightness = type === 'light' || type === 'curtain'
    ? Math.max(0, Math.min(100, typeof merged.brightness === 'number' ? Math.round(merged.brightness) : (merged.enabled ? 72 : 0)))
    : undefined;
  const enabled = type === 'light' || type === 'curtain'
    ? merged.enabled === true && (brightness === undefined ? true : brightness > 0)
    : merged.enabled === true;
  return {
    deviceId: merged.deviceId || (fallback ? fallback.deviceId : ''),
    deviceType: type,
    deviceName: merged.deviceName || (fallback ? fallback.deviceName : 'device'),
    roomName: merged.roomName || (fallback ? fallback.roomName : 'room'),
    enabled,
    brightness,
    temperature: type === 'air'
      ? Math.max(16, Math.min(30, typeof merged.temperature === 'number' ? Math.round(merged.temperature) : 26))
      : undefined,
    mode: type === 'air'
      ? (merged.mode || '制冷')
      : (type === 'curtain' ? (merged.mode || '自动') : undefined),
    locked: type === 'door' ? merged.locked !== false : undefined
  };
}

function normalizeSceneModePreset(raw, fallbackMode) {
  const fallbackDevices = Array.isArray(fallbackMode.devices) ? fallbackMode.devices : [];
  const rawDevices = raw && Array.isArray(raw.devices) ? raw.devices : [];
  const devices = [];
  for (const fallbackDevice of fallbackDevices) {
    const matched = rawDevices.find((item) => item && item.deviceId === fallbackDevice.deviceId);
    devices.push(normalizeSceneDevicePreset(matched, fallbackDevice));
  }
  for (const rawDevice of rawDevices) {
    if (!rawDevice || !rawDevice.deviceId) {
      continue;
    }
    const exists = devices.find((item) => item.deviceId === rawDevice.deviceId);
    if (!exists) {
      devices.push(normalizeSceneDevicePreset(rawDevice, null));
    }
  }
  return {
    key: raw && raw.key ? raw.key : fallbackMode.key,
    label: raw && raw.label ? raw.label : fallbackMode.label,
    builtIn: fallbackMode.builtIn === true,
    devices
  };
}

function alignSceneConfigToRooms(config, rooms) {
  const normalized = normalizeSceneConfig(config);
  const alignMode = (modeKey, modePreset, builtIn) => {
    const meta = sceneModeMeta(modeKey);
    const fallbackMode = buildSceneModeFromRooms(modeKey, modePreset && modePreset.label ? modePreset.label : meta.label, rooms, builtIn);
    return normalizeSceneModePreset(modePreset, fallbackMode);
  };
  return {
    home: alignMode('home', normalized.home, true),
    away: alignMode('away', normalized.away, true),
    sleep: alignMode('sleep', normalized.sleep, true),
    energy: alignMode('energy', normalized.energy, true),
    customModes: Array.isArray(normalized.customModes)
      ? normalized.customModes.map((item, index) => {
        const key = item && item.key ? item.key : `custom_${index}`;
          const label = item && item.label ? item.label : `自定义场景 ${index + 1}`;
        return normalizeSceneModePreset(item, buildSceneModeFromRooms(key, label, rooms, false));
      })
      : []
  };
}

function normalizeSceneConfig(config) {
  const defaults = defaultSceneConfig();
  if (!config || typeof config !== 'object') {
    return defaults;
  }
  if (Array.isArray(config.homeTypes) || Array.isArray(config.awayTypes) || Array.isArray(config.sleepTypes) || Array.isArray(config.energyTypes)) {
    const homeTypes = Array.isArray(config.homeTypes) ? config.homeTypes : ['light', 'air'];
    const awayTypes = Array.isArray(config.awayTypes) ? config.awayTypes : ['door'];
    const sleepTypes = Array.isArray(config.sleepTypes) ? config.sleepTypes : ['light', 'air', 'door'];
    const energyTypes = Array.isArray(config.energyTypes) ? config.energyTypes : ['air'];
    const emptyRooms = [];
    const home = buildSceneModeFromRooms('home', '回家模式', emptyRooms, true);
    const away = buildSceneModeFromRooms('away', '离家模式', emptyRooms, true);
    const sleep = buildSceneModeFromRooms('sleep', '睡眠模式', emptyRooms, true);
    const energy = buildSceneModeFromRooms('energy', '节能模式', emptyRooms, true);
    return { home, away, sleep, energy, customModes: [] };
  }

  if (config.home && Array.isArray(config.home.devices)) {
    return {
      home: normalizeSceneModePreset(config.home, defaults.home),
      away: normalizeSceneModePreset(config.away, defaults.away),
      sleep: normalizeSceneModePreset(config.sleep, defaults.sleep),
      energy: normalizeSceneModePreset(config.energy, defaults.energy),
      customModes: Array.isArray(config.customModes)
        ? config.customModes.map((item, index) => {
          const meta = sceneModeMeta(item && item.key ? item.key : `custom_${index}`);
          return normalizeSceneModePreset(item, {
            key: meta.key,
            label: item && item.label ? item.label : meta.label,
            builtIn: false,
            devices: []
          });
        })
        : []
    };
  }

  return {
    home: Object.assign({}, defaults.home, config.home || {}),
    away: Object.assign({}, defaults.away, config.away || {}),
    sleep: Object.assign({}, defaults.sleep, config.sleep || {}),
    energy: Object.assign({}, defaults.energy, config.energy || {}),
    customModes: Array.isArray(config.customModes) ? config.customModes : []
  };
}

function ensureMemoryUser(username) {
  const existed = memoryStore.users.find((item) => item.username === username);
  if (!existed) {
    return null;
  }
  if (!memoryStore.roomsByUsername[username]) {
    memoryStore.roomsByUsername[username] = [];
  }
  if (!memoryStore.logsByUsername[username]) {
    memoryStore.logsByUsername[username] = [];
  }
  if (!memoryStore.doorSecurityByUsername[username]) {
    memoryStore.doorSecurityByUsername[username] = {};
  }
  if (!memoryStore.sceneConfigByUsername[username]) {
    memoryStore.sceneConfigByUsername[username] = defaultSceneConfig();
  }
  if (!memoryStore.currentModeByUsername[username]) {
    memoryStore.currentModeByUsername[username] = 'home';
  }
  if (!memoryStore.environmentByUsername[username]) {
    memoryStore.environmentByUsername[username] = defaultEnvironmentConfig();
  }
  if (!memoryStore.utilityByUsername[username]) {
    memoryStore.utilityByUsername[username] = defaultUtilityAccount();
  }
  if (!memoryStore.familyMembersByUsername[username]) {
    memoryStore.familyMembersByUsername[username] = [];
  }
  if (!memoryStore.doorCameraByUsername[username]) {
    memoryStore.doorCameraByUsername[username] = {};
  }
  return existed;
}

async function initDatabase() {
  if (!mysqlConfigReady()) {
    console.log('Database not configured, using memory mode.');
    return;
  }

  let mysql = null;
  try {
    mysql = require('mysql2/promise');
  } catch (error) {
    console.log('mysql2 not installed, using memory mode.');
    return;
  }

  dbPool = mysql.createPool({
    host: process.env.MYSQL_HOST || '127.0.0.1',
    port: Number(process.env.MYSQL_PORT || 3306),
    user: process.env.MYSQL_USER || 'root',
    password: process.env.MYSQL_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || 'hongju_control',
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true
  });

  await ensureTables();
  await seedDatabaseIfEmpty();
  dbMode = 'mysql';
  console.log('MySQL enabled, device state and logs will persist.');
}

async function ensureTables() {
  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(64) NOT NULL UNIQUE,
      password_plain VARCHAR(128) NOT NULL,
      role VARCHAR(32) NOT NULL DEFAULT 'user',
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS rooms (
      id VARCHAR(64) PRIMARY KEY,
      name VARCHAR(64) NOT NULL,
      sort_order INT NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await ensureColumn('rooms', 'user_id', 'INT NOT NULL DEFAULT 1');

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS devices (
      id VARCHAR(64) PRIMARY KEY,
      room_id VARCHAR(64) NOT NULL,
      type VARCHAR(32) NOT NULL,
      name VARCHAR(64) NOT NULL,
      power TINYINT(1) NOT NULL DEFAULT 0,
      locked TINYINT(1) NULL,
      brightness INT NULL,
      temperature INT NULL,
      mode VARCHAR(32) NULL,
      metadata TEXT NULL,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_devices_room_id (room_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await ensureColumn('devices', 'brightness', 'INT NULL');
  await ensureColumn('devices', 'metadata', 'TEXT NULL');

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS device_states (
      id INT AUTO_INCREMENT PRIMARY KEY,
      device_id VARCHAR(64) NOT NULL,
      power TINYINT(1) NOT NULL DEFAULT 0,
      locked TINYINT(1) NULL,
      brightness INT NULL,
      temperature INT NULL,
      mode VARCHAR(32) NULL,
      metadata TEXT NULL,
      recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_device_states_device_id (device_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await ensureColumn('device_states', 'brightness', 'INT NULL');
  await ensureColumn('device_states', 'metadata', 'TEXT NULL');

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS operation_logs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      action VARCHAR(64) NOT NULL,
      target VARCHAR(64) NOT NULL,
      detail VARCHAR(255) NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await ensureColumn('operation_logs', 'user_id', 'INT NOT NULL DEFAULT 1');

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS scene_modes (
      id VARCHAR(64) PRIMARY KEY,
      name VARCHAR(64) NOT NULL,
      payload TEXT NULL,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await ensureColumn('scene_modes', 'user_id', 'INT NOT NULL DEFAULT 1');

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS sensor_records (
      id INT AUTO_INCREMENT PRIMARY KEY,
      room_id VARCHAR(64) NOT NULL,
      temperature DECIMAL(5,2) NULL,
      humidity DECIMAL(5,2) NULL,
      recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_sensor_records_room_id (room_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS door_camera_videos (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      device_id VARCHAR(64) NOT NULL,
      video_url VARCHAR(255) NOT NULL,
      cover_url VARCHAR(255) NULL,
      captured_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      duration_sec INT NULL,
      camera_status VARCHAR(32) NOT NULL DEFAULT 'normal',
      notes VARCHAR(255) NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_door_camera_user (user_id),
      INDEX idx_door_camera_device_time (device_id, captured_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS utility_accounts (
      user_id INT PRIMARY KEY,
      electric_balance DECIMAL(10,2) NOT NULL DEFAULT 0,
      gas_balance DECIMAL(10,2) NOT NULL DEFAULT 0,
      water_balance DECIMAL(10,2) NOT NULL DEFAULT 0,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_utility_accounts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await dbPool.query(`
    CREATE TABLE IF NOT EXISTS family_members (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      name VARCHAR(64) NOT NULL,
      phone VARCHAR(32) NOT NULL,
      role_label VARCHAR(32) NOT NULL DEFAULT '家庭成员',
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_family_user_phone (user_id, phone),
      INDEX idx_family_user (user_id),
      CONSTRAINT fk_family_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
}

async function ensureColumn(tableName, columnName, definition) {
  const [rows] = await dbPool.query(
    `SELECT COUNT(*) AS total
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = ?
       AND COLUMN_NAME = ?`,
    [tableName, columnName]
  );

  if (rows[0].total > 0) {
    return;
  }

  await dbPool.query(`ALTER TABLE \`${tableName}\` ADD COLUMN \`${columnName}\` ${definition}`);
}

async function getUserByUsername(username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT id, username, password_plain, role FROM users WHERE username = ? LIMIT 1`,
      [username]
    );
    if (rows.length === 0) {
      return null;
    }
    return rows[0];
  }

  const user = ensureMemoryUser(username);
  return user ? clone(user) : null;
}

async function createUser(username, password) {
  if (dbPool) {
    const existed = await getUserByUsername(username);
    if (existed) {
      return { error: '用户名已存在' };
    }
    const [result] = await dbPool.query(
      `INSERT INTO users (username, password_plain, role) VALUES (?, ?, 'user')`,
      [username, password]
    );
    const user = { id: result.insertId, username, role: 'user' };
    await saveSceneConfig(user.id, username, defaultSceneConfig());
    await saveCurrentMode(user.id, username, 'home');
    await saveUtilityAccount(user.id, username, defaultUtilityAccount());
    return user;
  }

  const existed = memoryStore.users.find((item) => item.username === username);
  if (existed) {
    return { error: '用户名已存在' };
  }
  const newUser = {
    id: memoryStore.users.length + 1,
    username,
    password_plain: password,
    role: 'user'
  };
  memoryStore.users.push(newUser);
  ensureMemoryUser(username);
  return clone(newUser);
}

async function validateUser(username, password) {
  const user = await getUserByUsername(username);
  if (!user) {
    return null;
  }
  if (user.password_plain !== password) {
    return null;
  }
  return user;
}

async function seedDatabaseIfEmpty() {
  const demoUser = await getUserByUsername(USERNAME);
  if (!demoUser) {
    await dbPool.query(
      `INSERT INTO users (username, password_plain, role) VALUES (?, ?, 'linjiaqi')`,
      [USERNAME, PASSWORD]
    );
  }
  const currentDemoUser = await getUserByUsername(USERNAME);
  await ensureDefaultDemoDevices(currentDemoUser);

  await saveSceneConfig(currentDemoUser.id, currentDemoUser.username, defaultSceneConfig());
  await saveCurrentMode(currentDemoUser.id, currentDemoUser.username, 'home');
}

async function ensureDefaultDemoDevices(user) {
  await dbPool.query(
    `DELETE FROM devices
     WHERE type IN ('smoke', 'gas')
       AND room_id IN (SELECT id FROM rooms WHERE user_id = ?)`,
    [user.id]
  );
  for (let roomIndex = 0; roomIndex < defaultAdminRooms.length; roomIndex += 1) {
    const room = defaultAdminRooms[roomIndex];
    await dbPool.query(
      `INSERT INTO rooms (id, user_id, name, sort_order)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         user_id = VALUES(user_id),
         name = VALUES(name),
         sort_order = VALUES(sort_order)`,
      [room.id, user.id, room.name, roomIndex]
    );

    for (const rawDevice of room.devices) {
      const device = ensureDeviceDefaults(Object.assign({}, rawDevice));
      await dbPool.query(
        `INSERT INTO devices (id, room_id, type, name, power, locked, brightness, temperature, mode, metadata, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
         ON DUPLICATE KEY UPDATE
           room_id = VALUES(room_id),
           type = VALUES(type),
           name = VALUES(name),
           metadata = VALUES(metadata),
           updated_at = NOW()`,
        [
          device.id,
          room.id,
          device.type,
          device.name,
          boolToTinyInt(device.power),
          device.locked === undefined ? null : boolToTinyInt(device.locked),
          device.brightness === undefined ? null : device.brightness,
          device.temperature === undefined ? null : device.temperature,
          device.mode || null,
          metadataPayload(device)
        ]
      );
    }
  }
}

async function getRoomsForUser(userId, username) {
  if (dbPool) {
    const doorSecurityMap = await getDoorSecurityMap(userId, username);
    const [roomRows] = await dbPool.query(
      `SELECT id, name FROM rooms WHERE user_id = ? ORDER BY sort_order ASC, created_at ASC`,
      [userId]
    );
    const [deviceRows] = await dbPool.query(
      `SELECT id, room_id, type, name, power, locked, brightness, temperature, mode, metadata
       FROM devices
       WHERE room_id IN (SELECT id FROM rooms WHERE user_id = ?)
       ORDER BY created_at ASC`,
      [userId]
    );
    return roomRows.map((room) => ({
      id: room.id,
      name: normalizeRoomName(room.name),
      devices: deviceRows
        .filter((device) => device.room_id === room.id)
        .map((device) => {
          const baseDevice = applyMetadataToDevice({
            id: device.id,
            type: device.type,
            name: device.name,
            power: tinyIntToBool(device.power),
            locked: device.locked === null ? undefined : tinyIntToBool(device.locked),
            brightness: device.brightness === null ? undefined : device.brightness,
            temperature: device.temperature === null ? undefined : device.temperature,
            mode: device.mode || undefined
          }, device.metadata);
          ensureDeviceDefaults(baseDevice);
          if (baseDevice.type === 'door') {
            return mergeDoorSecurity(baseDevice, doorSecurityMap[baseDevice.id]);
          }
          return baseDevice;
        })
    }));
  }

  ensureMemoryUser(username);
  const doorSecurityMap = clone(memoryStore.doorSecurityByUsername[username] || {});
  return clone(memoryStore.roomsByUsername[username]).map((room) => ({
    id: room.id,
    name: normalizeRoomName(room.name),
    devices: room.devices.map((device) => {
      const normalizedDevice = ensureDeviceDefaults(device);
      if (normalizedDevice.type === 'door') {
        return mergeDoorSecurity(normalizedDevice, doorSecurityMap[normalizedDevice.id]);
      }
      return normalizedDevice;
    })
  }));
}

async function getLogsForUser(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT id, created_at, action, target, detail
       FROM operation_logs
       WHERE user_id = ?
       ORDER BY id DESC
       LIMIT 50`,
      [userId]
    );
    return rows.map((row) => ({
      id: row.id,
      time: new Date(row.created_at).toISOString(),
      action: row.action,
      target: row.target,
      detail: row.detail
    }));
  }

  ensureMemoryUser(username);
  return clone(memoryStore.logsByUsername[username]);
}

async function addLog(userId, username, action, target, detail) {
  const logTime = now();
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO operation_logs (user_id, action, target, detail, created_at) VALUES (?, ?, ?, ?, ?)`,
      [userId, action, target, detail, toMysqlDate(logTime)]
    );
    return;
  }

  ensureMemoryUser(username);
  memoryStore.logsByUsername[username] = [
    {
      id: memoryStore.nextLogId++,
      time: logTime,
      action,
      target,
      detail
    },
    ...memoryStore.logsByUsername[username]
  ].slice(0, 50);
}

async function getSceneConfig(userId, username) {
  const rooms = await getRoomsForUser(userId, username);
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT payload FROM scene_modes WHERE id = ? AND user_id = ? LIMIT 1`,
      [`${username}_home`, userId]
    );
    if (rows.length === 0) {
      return alignSceneConfigToRooms(defaultSceneConfig(), rooms);
    }
    try {
      return alignSceneConfigToRooms(JSON.parse(rows[0].payload), rooms);
    } catch (error) {
      return alignSceneConfigToRooms(defaultSceneConfig(), rooms);
    }
  }

  ensureMemoryUser(username);
  return alignSceneConfigToRooms(clone(memoryStore.sceneConfigByUsername[username]), rooms);
}

async function saveSceneConfig(userId, username, config) {
  const rooms = await getRoomsForUser(userId, username);
  const normalized = alignSceneConfigToRooms(config, rooms);
  const payload = JSON.stringify(normalized);
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO scene_modes (id, user_id, name, payload, updated_at)
       VALUES (?, ?, '回家模式预设', ?, NOW())
       ON DUPLICATE KEY UPDATE payload = VALUES(payload), updated_at = NOW(), user_id = VALUES(user_id)`,
      [`${username}_home`, userId, payload]
    );
    return;
  }

  ensureMemoryUser(username);
  memoryStore.sceneConfigByUsername[username] = clone(normalized);
}

async function getCurrentMode(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT payload FROM scene_modes WHERE id = ? AND user_id = ? LIMIT 1`,
      [`${username}_current`, userId]
    );
    if (rows.length === 0) {
      return 'home';
    }
    try {
      const data = JSON.parse(rows[0].payload);
      return data.mode || 'home';
    } catch (error) {
      return 'home';
    }
  }

  ensureMemoryUser(username);
  return memoryStore.currentModeByUsername[username] || 'home';
}

async function saveCurrentMode(userId, username, mode) {
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO scene_modes (id, user_id, name, payload, updated_at)
       VALUES (?, ?, '当前模式', ?, NOW())
       ON DUPLICATE KEY UPDATE payload = VALUES(payload), updated_at = NOW(), user_id = VALUES(user_id)`,
      [`${username}_current`, userId, JSON.stringify({ mode })]
    );
    return;
  }

  ensureMemoryUser(username);
  memoryStore.currentModeByUsername[username] = mode;
}

async function getEnvironmentConfig(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT payload FROM scene_modes WHERE id = ? AND user_id = ? LIMIT 1`,
      [`${username}_environment`, userId]
    );
    if (rows.length === 0) {
      return defaultEnvironmentConfig();
    }
    try {
      return Object.assign({}, defaultEnvironmentConfig(), JSON.parse(rows[0].payload));
    } catch (error) {
      return defaultEnvironmentConfig();
    }
  }

  ensureMemoryUser(username);
  return clone(memoryStore.environmentByUsername[username] || defaultEnvironmentConfig());
}

async function saveEnvironmentConfig(userId, username, environment) {
  const payload = JSON.stringify(environment);
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO scene_modes (id, user_id, name, payload, updated_at)
       VALUES (?, ?, '环境监测', ?, NOW())
       ON DUPLICATE KEY UPDATE payload = VALUES(payload), updated_at = NOW(), user_id = VALUES(user_id)`,
      [`${username}_environment`, userId, payload]
    );
    return;
  }

  ensureMemoryUser(username);
  memoryStore.environmentByUsername[username] = clone(environment);
}

async function getDoorSecurityMap(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT id, payload
       FROM scene_modes
       WHERE user_id = ?
         AND id LIKE 'door_security_%'`,
      [userId]
    );
    const result = {};
    rows.forEach((row) => {
      try {
        result[row.id.replace('door_security_', '')] = JSON.parse(row.payload);
      } catch (error) {
        result[row.id.replace('door_security_', '')] = {};
      }
    });
    return result;
  }

  ensureMemoryUser(username);
  return clone(memoryStore.doorSecurityByUsername[username] || {});
}

async function saveDoorSecurity(userId, username, deviceId, security) {
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO scene_modes (id, user_id, name, payload, updated_at)
       VALUES (?, ?, 'door_security', ?, NOW())
       ON DUPLICATE KEY UPDATE payload = VALUES(payload), updated_at = NOW(), user_id = VALUES(user_id)`,
      [`door_security_${deviceId}`, userId, JSON.stringify(security)]
    );
    return;
  }

  ensureMemoryUser(username);
  memoryStore.doorSecurityByUsername[username][deviceId] = clone(security);
}

async function getUtilityAccount(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT electric_balance, gas_balance, water_balance
       FROM utility_accounts
       WHERE user_id = ?
       LIMIT 1`,
      [userId]
    );
    if (rows.length === 0) {
      const defaults = defaultUtilityAccount();
      await saveUtilityAccount(userId, username, defaults);
      return defaults;
    }
    return {
      electricBalance: Number(rows[0].electric_balance || 0),
      gasBalance: Number(rows[0].gas_balance || 0),
      waterBalance: Number(rows[0].water_balance || 0)
    };
  }

  ensureMemoryUser(username);
  return clone(memoryStore.utilityByUsername[username] || defaultUtilityAccount());
}

async function saveUtilityAccount(userId, username, account) {
  const normalized = {
    electricBalance: Math.max(0, Number(account.electricBalance || 0)),
    gasBalance: Math.max(0, Number(account.gasBalance || 0)),
    waterBalance: Math.max(0, Number(account.waterBalance || 0))
  };

  if (dbPool) {
    await dbPool.query(
      `INSERT INTO utility_accounts (user_id, electric_balance, gas_balance, water_balance, updated_at)
       VALUES (?, ?, ?, ?, NOW())
       ON DUPLICATE KEY UPDATE
         electric_balance = VALUES(electric_balance),
         gas_balance = VALUES(gas_balance),
         water_balance = VALUES(water_balance),
         updated_at = NOW()`,
      [userId, normalized.electricBalance, normalized.gasBalance, normalized.waterBalance]
    );
    return normalized;
  }

  ensureMemoryUser(username);
  memoryStore.utilityByUsername[username] = clone(normalized);
  return normalized;
}

async function rechargeUtilityAccount(user, utilityType, amount) {
  const numericAmount = Number(amount);
  if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
    return { error: '充值金额必须大于 0' };
  }

  const normalizedAmount = Math.round(numericAmount * 100) / 100;
  const account = await getUtilityAccount(user.id, user.username);
  if (utilityType === 'electric') {
    account.electricBalance = Math.round((account.electricBalance + normalizedAmount) * 100) / 100;
  } else if (utilityType === 'gas') {
    account.gasBalance = Math.round((account.gasBalance + normalizedAmount) * 100) / 100;
  } else if (utilityType === 'water') {
    account.waterBalance = Math.round((account.waterBalance + normalizedAmount) * 100) / 100;
  } else {
    return { error: 'unsupported utility type' };
  }

  const saved = await saveUtilityAccount(user.id, user.username, account);
  return { account: saved, amount: normalizedAmount };
}

async function getFamilyMembers(userId, username) {
  if (dbPool) {
    const [rows] = await dbPool.query(
      `SELECT id, name, phone, role_label, created_at
       FROM family_members
       WHERE user_id = ?
       ORDER BY created_at ASC, id ASC`,
      [userId]
    );
    return rows.map((item) => ({
      id: item.id,
      name: item.name,
      phone: item.phone,
      roleLabel: item.role_label,
      createdAt: item.created_at
    }));
  }

  ensureMemoryUser(username);
  return clone(memoryStore.familyMembersByUsername[username] || []);
}

async function addFamilyMember(user, name, phone) {
  const normalizedName = `${name || ''}`.trim();
  const normalizedPhone = `${phone || ''}`.trim();
  if (!normalizedName) {
      return { error: '家人姓名不能为空' };
  }
  if (!/^1\d{10}$/.test(normalizedPhone)) {
    return { error: '请输入 11 位手机号' };
  }

  if (dbPool) {
    const [exists] = await dbPool.query(
      `SELECT id FROM family_members WHERE user_id = ? AND phone = ? LIMIT 1`,
      [user.id, normalizedPhone]
    );
    if (exists.length > 0) {
      return { error: '该手机号已添加到家庭成员' };
    }
    const [result] = await dbPool.query(
      `INSERT INTO family_members (user_id, name, phone, role_label) VALUES (?, ?, ?, ?)`,
      [user.id, normalizedName, normalizedPhone, '家庭成员']
    );
    return {
      member: {
        id: result.insertId,
        name: normalizedName,
        phone: normalizedPhone,
        roleLabel: '家庭成员',
        createdAt: now()
      }
    };
  }

  ensureMemoryUser(user.username);
  const exists = memoryStore.familyMembersByUsername[user.username]
    .find((item) => item.phone === normalizedPhone);
  if (exists) {
    return { error: '该手机号已添加到家庭成员' };
  }
  const member = {
    id: memoryStore.nextFamilyId,
    name: normalizedName,
    phone: normalizedPhone,
    roleLabel: '家庭成员',
    createdAt: now()
  };
  memoryStore.nextFamilyId += 1;
  memoryStore.familyMembersByUsername[user.username].push(member);
  return { member: clone(member) };
}

function normalizeCameraRecord(row) {
  if (!row) {
    return null;
  }
  const resolvedVideoUrl = normalizeMediaUrl(row.video_url || row.videoUrl || '');
  const resolvedCoverUrl = normalizeMediaUrl(row.cover_url || row.coverUrl || '') || resolvedVideoUrl;
  return {
    id: row.id || 0,
    deviceId: row.device_id || row.deviceId || '',
    videoUrl: resolvedVideoUrl,
    coverUrl: resolvedCoverUrl,
    capturedAt: row.captured_at
      ? new Date(row.captured_at).toISOString()
      : (row.capturedAt || now()),
    durationSec: row.duration_sec === null || row.duration_sec === undefined
      ? null
      : Number(row.duration_sec),
    cameraStatus: row.camera_status || row.cameraStatus || 'normal',
    notes: row.notes || ''
  };
}

function fallbackCameraRecord(device) {
  return {
    id: 0,
    deviceId: device.id,
    videoUrl: '',
    coverUrl: '',
    capturedAt: now(),
    durationSec: null,
    cameraStatus: device.cameraStatus === 'alert' ? 'alert' : 'normal',
    notes: 'no door camera record yet'
  };
}

function doorDeviceAliases(deviceId) {
  const aliases = [];
  [deviceId, 'entrance_door', 'bedroom_door'].forEach((item) => {
    if (item && aliases.indexOf(item) < 0) {
      aliases.push(item);
    }
  });
  return aliases;
}

async function getLatestDoorCameraRecord(userId, deviceId) {
  if (!dbPool) {
    const user = memoryStore.users.find((item) => item.id === userId);
    if (!user) {
      return null;
    }
    ensureMemoryUser(user.username);
    const records = memoryStore.doorCameraByUsername[user.username] || {};
    const aliases = doorDeviceAliases(deviceId);
    for (const alias of aliases) {
      if (records[alias]) {
        return normalizeCameraRecord(records[alias]);
      }
    }
    return null;
  }

  const aliases = doorDeviceAliases(deviceId);
  const placeholders = aliases.map(() => '?').join(', ');
  const [rows] = await dbPool.query(
    `SELECT id, user_id, device_id, video_url, cover_url, captured_at, duration_sec, camera_status, notes
     FROM door_camera_videos
     WHERE user_id = ?
       AND device_id IN (${placeholders})
     ORDER BY captured_at DESC, id DESC
     LIMIT 1`,
    [userId, ...aliases]
  );

  if (rows.length === 0) {
    return null;
  }
  return normalizeCameraRecord(rows[0]);
}

async function saveDoorCameraRecord(user, deviceId, record) {
  const normalized = normalizeCameraRecord(record);
  if (!normalized) {
    return null;
  }

  if (dbPool) {
    await dbPool.query(
      `INSERT INTO door_camera_videos
       (user_id, device_id, video_url, cover_url, captured_at, duration_sec, camera_status, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        user.id,
        deviceId,
        normalized.videoUrl,
        normalized.coverUrl || normalized.videoUrl || null,
        toMysqlDate(normalized.capturedAt),
        normalized.durationSec,
        normalized.cameraStatus || 'normal',
        normalized.notes || null
      ]
    );
    return getLatestDoorCameraRecord(user.id, deviceId);
  }

  ensureMemoryUser(user.username);
  memoryStore.doorCameraByUsername[user.username][deviceId] = clone({
    id: normalized.id || Date.now(),
    deviceId,
    videoUrl: normalized.videoUrl,
    coverUrl: normalized.coverUrl || normalized.videoUrl || '',
    capturedAt: normalized.capturedAt,
    durationSec: normalized.durationSec,
    cameraStatus: normalized.cameraStatus || 'normal',
    notes: normalized.notes || ''
  });
  return normalizeCameraRecord(memoryStore.doorCameraByUsername[user.username][deviceId]);
}

async function buildStateForUser(username) {
  const user = await getUserByUsername(username);
  if (!user) {
    return null;
  }

  const rooms = await getRoomsForUser(user.id, username);
  await advanceRobotCleaningProgress(user, rooms);
  const logs = await getLogsForUser(user.id, username);
  const sceneConfig = await getSceneConfig(user.id, username);
  const currentMode = await getCurrentMode(user.id, username);
  const environmentConfig = await getEnvironmentConfig(user.id, username);
  const environment = buildEnvironmentMetrics(rooms, environmentConfig);
  const utilityAccount = await getUtilityAccount(user.id, username);
  const familyMembers = await getFamilyMembers(user.id, username);
  const allDoors = rooms.flatMap((room) => room.devices.filter((device) => device.type === 'door'));
  const entranceDoor = allDoors.find((device) => device.id === 'entrance_door') || allDoors[0] || null;
  const latestDoorCamera = entranceDoor
    ? ((await getLatestDoorCameraRecord(user.id, entranceDoor.id)) || fallbackCameraRecord(entranceDoor))
    : null;

  return {
    homeName: buildHomeName(username),
    mode: currentMode,
    updatedAt: now(),
    rooms,
    logs,
    sceneConfig,
    environment,
    utilityAccount,
    familyMembers,
    latestDoorCamera
  };
}

function findRoomByName(rooms, roomName) {
  return rooms.find((room) => isSameRoomName(room.name, roomName));
}

function findDeviceInRooms(rooms, deviceId) {
  for (const room of rooms) {
    const device = room.devices.find((item) => item.id === deviceId);
    if (device) {
      return { room, device };
    }
  }
  return null;
}

async function ensureRoomForUser(user, roomName) {
  const normalizedRoomName = normalizeRoomName(roomName);
  const rooms = await getRoomsForUser(user.id, user.username);
  const existed = findRoomByName(rooms, normalizedRoomName);
  if (existed) {
    return existed;
  }

  const roomId = `room_${Date.now()}`;
  if (dbPool) {
    await dbPool.query(
      `INSERT INTO rooms (id, user_id, name, sort_order) VALUES (?, ?, ?, ?)`,
      [roomId, user.id, normalizedRoomName, rooms.length]
    );
  } else {
    ensureMemoryUser(user.username);
    memoryStore.roomsByUsername[user.username] = [
      ...memoryStore.roomsByUsername[user.username],
      { id: roomId, name: normalizedRoomName, devices: [] }
    ];
  }
  await addLog(user.id, user.username, 'ROOM_CREATE', normalizedRoomName, '已添加新房间');
  return { id: roomId, name: normalizedRoomName, devices: [] };
}

function guessDeviceType(name) {
  if (name.includes('空调') || name.includes('绌鸿皟')) {
    return 'air';
  }
  if (name.includes('扫地') || name.includes('清扫') || name.toLowerCase().includes('robot')) {
    return 'robot';
  }
  if (name.includes('door') || name.includes('lock')) {
    return 'door';
  }
  if (name.includes('电视') || name.includes('鐢佃')) {
    return 'tv';
  }
  if (name.includes('绐楀笜')) {
    return 'curtain';
  }
  return 'light';
}

function normalizeType(type) {
  const value = `${type || ''}`.trim();
  if (value === '空调' || value === '智能空调') {
    return 'air';
  }
  if (value === '门禁' || value === '门锁' || value === '智能门锁') {
    return 'door';
  }
  if (value === '灯光' || value === '灯' || value === '照明') {
    return 'light';
  }
  if (value === '窗帘' || value === '智能窗帘') {
    return 'curtain';
  }
  if (value === '音箱' || value === '智能音箱') {
    return 'speaker';
  }
  if (value === '扫地机器人' || value === '机器人' || value === '扫地机') {
    return 'robot';
  }
  if (type === 'airConditioner') {
    return 'air';
  }
  if (type === 'doorLock') {
    return 'door';
  }
  if (type === 'lighting') {
    return 'light';
  }
  if (type === 'curtains' || type === 'smartCurtain') {
    return 'curtain';
  }
  if (type === 'smartSpeaker') {
    return 'speaker';
  }
  if (type === 'vacuum' || type === 'cleanRobot' || type === 'sweeper') {
    return 'robot';
  }
  return type || 'other';
}

function parseMetadata(value) {
  if (!value) {
    return {};
  }
  if (typeof value === 'object') {
    return clone(value);
  }
  try {
    return JSON.parse(value);
  } catch (error) {
    return {};
  }
}

function buildDeviceMetadata(device) {
  const metadata = parseMetadata(device.metadata);
  [
    'brand',
    'protocol',
    'adapter',
    'listening',
    'lastCommand',
    'lastBroadcast',
    'musicTrackId',
    'musicTitle',
    'musicArtist',
    'musicUrl',
    'musicPlaying',
    'musicStartedAt',
    'cleanMode',
    'activityArea',
    'battery',
    'cleaningProgress',
    'robotProgressUpdatedAt'
  ].forEach((key) => {
    if (device[key] !== undefined) {
      metadata[key] = device[key];
    }
  });
  return metadata;
}

function applyMetadataToDevice(device, metadata) {
  const result = Object.assign({}, device);
  const resolved = parseMetadata(metadata);
  Object.keys(resolved).forEach((key) => {
    result[key] = resolved[key];
  });
  delete result.metadata;
  return result;
}

function metadataPayload(device) {
  const metadata = buildDeviceMetadata(device);
  return Object.keys(metadata).length > 0 ? JSON.stringify(metadata) : null;
}

function ensureDeviceDefaults(device) {
  const type = normalizeType(device.type);
  device.type = type;
  if (type === 'light') {
    device.brightness = typeof device.brightness === 'number' ? device.brightness : (device.power ? 72 : 0);
  }
  if (type === 'air') {
    device.temperature = typeof device.temperature === 'number' ? device.temperature : 26;
    device.mode = device.mode || '制冷';
  }
  if (type === 'speaker') {
    device.power = device.power !== false;
    device.listening = device.listening !== false;
    device.lastCommand = device.lastCommand || '';
    device.lastBroadcast = device.lastBroadcast || '等待播报';
    const musicLibrary = getMusicLibrary();
    const track = musicLibrary.find((item) => item.id === device.musicTrackId) || getPreferredMusicTrack();
    const preferredTrack = getPreferredMusicTrack();
    const shouldPromotePreferredTrack = !device.musicTrackId
      || device.musicTrackId === BUILTIN_DEMO_TRACK.id
      || device.musicUrl === BUILTIN_DEMO_TRACK.url;
    const activeTrack = shouldPromotePreferredTrack ? preferredTrack : track;
    device.musicTrackId = activeTrack.id;
    device.musicTitle = activeTrack.title;
    device.musicArtist = activeTrack.artist;
    device.musicUrl = activeTrack.url;
    device.musicPlaying = device.musicPlaying === true;
  }
  if (type === 'robot') {
    device.cleanMode = 'auto';
    device.activityArea = device.activityArea || '客厅';
    device.battery = typeof device.battery === 'number' ? device.battery : 86;
    device.cleaningProgress = typeof device.cleaningProgress === 'number'
      ? clamp(Math.round(device.cleaningProgress), 0, 100)
      : (device.power ? 24 : 0);
  }
  return device;
}

function advanceRobotDeviceProgress(device, timestampMs) {
  if (normalizeType(device.type) !== 'robot' || !device.power) {
    return false;
  }

  ensureDeviceDefaults(device);
  const previousProgress = clamp(Math.round(device.cleaningProgress || 0), 0, 100);
  const previousTick = Date.parse(device.robotProgressUpdatedAt || '');
  const elapsedMs = Number.isFinite(previousTick)
    ? timestampMs - previousTick
    : ROBOT_PROGRESS_INTERVAL_MS;

  if (elapsedMs < ROBOT_PROGRESS_INTERVAL_MS) {
    return false;
  }

  const steps = Math.max(1, Math.floor(elapsedMs / ROBOT_PROGRESS_INTERVAL_MS));
  let nextProgress = previousProgress + steps * ROBOT_PROGRESS_STEP;
  if (nextProgress > 100) {
    nextProgress %= 100;
    if (nextProgress === 0) {
      nextProgress = ROBOT_PROGRESS_STEP;
    }
  }

  device.cleaningProgress = clamp(Math.round(nextProgress), 1, 100);
  device.robotProgressUpdatedAt = new Date(timestampMs).toISOString();
  return device.cleaningProgress !== previousProgress;
}

async function advanceRobotCleaningProgress(user, rooms) {
  const timestampMs = Date.now();
  for (const room of rooms) {
    for (const device of room.devices) {
      if (advanceRobotDeviceProgress(device, timestampMs)) {
        await saveDevice(user, room.id, device);
      }
    }
  }
}

async function createDeviceForUser(user, roomName, deviceName, type) {
  const room = await ensureRoomForUser(user, roomName);
  const deviceId = `device_${Date.now()}`;
  const normalizedType = normalizeType(type || guessDeviceType(deviceName));
  const device = {
    id: deviceId,
    type: normalizedType,
    name: deviceName,
    power: false
  };
  if (normalizedType === 'light') {
    device.brightness = 72;
  }
  if (normalizedType === 'curtain') {
    device.brightness = 60;
    device.mode = '自动';
    device.power = true;
  }
  if (normalizedType === 'door') {
    device.locked = true;
  }
  if (normalizedType === 'air') {
    device.temperature = 26;
    device.mode = '制冷';
  }
  if (normalizedType === 'robot') {
    device.cleanMode = 'auto';
    device.activityArea = room.name;
    device.battery = 86;
    device.cleaningProgress = 0;
  }
  ensureDeviceDefaults(device);

  if (dbPool) {
    await dbPool.query(
      `INSERT INTO devices (id, room_id, type, name, power, locked, brightness, temperature, mode, metadata, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        device.id,
        room.id,
        device.type,
        device.name,
        boolToTinyInt(device.power),
        device.locked === undefined ? null : boolToTinyInt(device.locked),
        device.brightness === undefined ? null : device.brightness,
        device.temperature === undefined ? null : device.temperature,
        device.mode || null,
        metadataPayload(device)
      ]
    );
  } else {
    ensureMemoryUser(user.username);
    memoryStore.roomsByUsername[user.username] = memoryStore.roomsByUsername[user.username].map((item) => {
      if (item.id !== room.id) {
        return item;
      }
      return {
        id: item.id,
        name: item.name,
        devices: [...item.devices, device]
      };
    });
  }

  await addLog(user.id, user.username, 'DEVICE_CREATE', device.name, 'added to ' + room.name);
  return { roomId: room.id, device };
}

async function deleteDeviceForUser(user, deviceId) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user not found' };
  }
  const target = findDeviceInRooms(userState.rooms, deviceId);
  if (!target) {
    return { error: 'device not found' };
  }

  if (dbPool) {
    await dbPool.query(`DELETE FROM device_states WHERE device_id = ?`, [deviceId]);
    await dbPool.query(`DELETE FROM door_camera_videos WHERE user_id = ? AND device_id = ?`, [user.id, deviceId]);
    await dbPool.query(`DELETE FROM scene_modes WHERE user_id = ? AND id = ?`, [user.id, `door_security_${deviceId}`]);
    await dbPool.query(`DELETE FROM devices WHERE id = ?`, [deviceId]);
  } else {
    ensureMemoryUser(user.username);
    memoryStore.roomsByUsername[user.username] = memoryStore.roomsByUsername[user.username].map((room) => ({
      id: room.id,
      name: room.name,
      devices: room.devices.filter((item) => item.id !== deviceId)
    }));
    if (memoryStore.doorSecurityByUsername[user.username]) {
      delete memoryStore.doorSecurityByUsername[user.username][deviceId];
    }
  }

  clearDoorAutomation(deviceId);
  await saveSceneConfig(user.id, user.username, await getSceneConfig(user.id, user.username));
  await addLog(user.id, user.username, 'DEVICE_DELETE', target.device.name, 'removed from ' + target.room.name);
  return { device: target.device, roomId: target.room.id };
}

async function saveDevice(user, roomId, device) {
  ensureDeviceDefaults(device);
  if (dbPool) {
    await dbPool.query(
      `UPDATE devices
       SET power = ?, locked = ?, brightness = ?, temperature = ?, mode = ?, metadata = ?, updated_at = NOW()
       WHERE id = ?`,
      [
        boolToTinyInt(device.power),
        device.locked === undefined ? null : boolToTinyInt(device.locked),
        device.brightness === undefined ? null : device.brightness,
        device.temperature === undefined ? null : device.temperature,
        device.mode || null,
        metadataPayload(device),
        device.id
      ]
    );
    await dbPool.query(
      `INSERT INTO device_states (device_id, power, locked, brightness, temperature, mode, metadata)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        device.id,
        boolToTinyInt(device.power),
        device.locked === undefined ? null : boolToTinyInt(device.locked),
        device.brightness === undefined ? null : device.brightness,
        device.temperature === undefined ? null : device.temperature,
        device.mode || null,
        metadataPayload(device)
      ]
    );
    return;
  }

  ensureMemoryUser(user.username);
  memoryStore.roomsByUsername[user.username] = memoryStore.roomsByUsername[user.username].map((room) => {
    if (room.id !== roomId) {
      return room;
    }
    return {
      id: room.id,
      name: room.name,
      devices: room.devices.map((item) => item.id === device.id ? clone(device) : item)
    };
  });
}

async function updateDeviceForUser(user, data, typeMode) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user not found' };
  }
  const target = findDeviceInRooms(userState.rooms, data.deviceId);
  if (!target) {
    return { error: 'device not found' };
  }
  const requestedType = normalizeType(data.type || '');
  const targetType = normalizeType(target.device.type);
  if (requestedType && requestedType !== 'other' && requestedType !== targetType) {
    return { error: 'device type mismatch' };
  }

  if (typeMode === 'door') {
    const locked = typeof data.locked === 'boolean' ? data.locked : !(target.device.locked === true);
    target.device.locked = locked;
    target.device.power = !locked;
    await saveDevice(user, target.room.id, target.device);
    await addLog(user.id, user.username, 'DOOR_CONTROL', target.device.name, locked ? '门禁已上锁' : '门禁已解锁');
  } else if (typeMode === 'air') {
    target.device.power = typeof data.power === 'boolean' ? data.power : !target.device.power;
    target.device.temperature = typeof data.temperature === 'number' ? data.temperature : (target.device.temperature || 26);
    target.device.mode = typeof data.mode === 'string' && data.mode.length > 0 ? data.mode : (target.device.mode || '制冷');
    await saveDevice(user, target.room.id, target.device);
    await addLog(
      user.id,
      user.username,
      'AIR_CONTROL',
      target.device.name,
      `空调${target.device.power ? '开启' : '关闭'} ${target.device.temperature || '--'}℃ ${target.device.mode || ''}`
    );
  } else if (typeMode === 'curtain') {
    if (typeof data.brightness === 'number') {
      target.device.brightness = Math.max(0, Math.min(100, Math.round(data.brightness)));
      target.device.power = target.device.brightness > 0;
    } else {
      target.device.power = typeof data.power === 'boolean' ? data.power : !target.device.power;
      target.device.brightness = target.device.power
        ? (typeof target.device.brightness === 'number' && target.device.brightness > 0 ? target.device.brightness : 100)
        : 0;
    }
    target.device.mode = typeof data.mode === 'string' && data.mode.length > 0 ? data.mode : (target.device.mode || '自动');
    await saveDevice(user, target.room.id, target.device);
    await addLog(
      user.id,
      user.username,
      'CURTAIN_CONTROL',
      target.device.name,
      `窗帘${target.device.power ? '开启' : '关闭'} 开合度 ${target.device.brightness || 0}% ${target.device.mode || ''}`
    );
  } else {
    const normalizedTargetType = normalizeType(target.device.type);
    target.device.power = typeof data.power === 'boolean'
      ? data.power
      : typeof data.lightOn === 'boolean'
        ? data.lightOn
        : !target.device.power;
    if (typeof data.brightness === 'number') {
      target.device.brightness = data.brightness;
      target.device.power = data.brightness > 0;
    } else if (normalizedTargetType === 'light' && target.device.power && target.device.brightness === undefined) {
      target.device.brightness = 72;
    } else if (normalizedTargetType === 'light' && !target.device.power) {
      target.device.brightness = 0;
    }
    if (normalizedTargetType === 'speaker') {
      if (typeof data.listening === 'boolean') {
        target.device.listening = data.listening;
      }
      const musicLibrary = getMusicLibrary();
      const track = musicLibrary.find((item) => item.id === data.musicTrackId) || getPreferredMusicTrack();
      if (typeof data.musicPlaying === 'boolean') {
        target.device.musicPlaying = data.musicPlaying;
        target.device.power = data.musicPlaying ? true : target.device.power;
        target.device.musicTrackId = track.id;
        target.device.musicTitle = track.title;
        target.device.musicArtist = track.artist;
        target.device.musicUrl = track.url;
        target.device.musicStartedAt = data.musicPlaying ? new Date().toISOString() : '';
      }
      if (typeof data.lastCommand === 'string') {
        target.device.lastCommand = data.lastCommand;
      }
      if (typeof data.lastBroadcast === 'string') {
        target.device.lastBroadcast = data.lastBroadcast;
      } else if (data.musicPlaying === true) {
        target.device.lastBroadcast = `正在播放：${track.title}`;
      } else if (data.musicPlaying === false) {
        target.device.lastBroadcast = '音乐已暂停';
      }
    }
    if (normalizedTargetType === 'robot') {
      target.device.cleanMode = 'auto';
      if (typeof data.activityArea === 'string' && data.activityArea.length > 0) {
        target.device.activityArea = data.activityArea;
      }
      if (typeof data.battery === 'number') {
        target.device.battery = clamp(Math.round(data.battery), 0, 100);
      }
      if (!target.device.power) {
        target.device.cleaningProgress = 0;
        target.device.robotProgressUpdatedAt = new Date().toISOString();
      } else {
        if (typeof data.cleaningProgress === 'number') {
          target.device.cleaningProgress = clamp(Math.round(data.cleaningProgress), 0, 100);
        } else {
          target.device.cleaningProgress = clamp((target.device.cleaningProgress || 0) + 18, 0, 100);
        }
        target.device.robotProgressUpdatedAt = new Date().toISOString();
      }
    }
    await saveDevice(user, target.room.id, target.device);
    let detail = target.device.power ? '设备已开启' : '设备已关闭';
    if (normalizedTargetType === 'speaker') {
      detail = target.device.musicPlaying
        ? `音箱自动播放：${target.device.musicTitle || '音乐'}`
        : `音箱播报：${target.device.lastBroadcast || '等待播报'}`;
    } else if (normalizedTargetType === 'robot') {
      detail = `扫地机器人${target.device.power ? '开始自动清扫' : '已停止'}，区域：${target.device.activityArea || target.room.name}`;
    } else if (normalizedTargetType === 'light' && target.device.brightness !== undefined) {
      detail = `灯光亮度 ${target.device.brightness}%`;
    }
    await addLog(
      user.id,
      user.username,
      typeMode === 'light' ? 'LIGHT_CONTROL' : 'DEVICE_CONTROL',
      target.device.name,
      detail
    );
  }

  return target.device;
}

function normalizeDoorSecurity(device, security) {
  return Object.assign({}, defaultDoorSecurity(device), security || {});
}

async function getDoorTarget(user, deviceId) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user not found' };
  }
  const target = findDeviceInRooms(userState.rooms, deviceId);
  if (!target || target.device.type !== 'door') {
    return { error: 'door device not found' };
  }
  const doorSecurityMap = await getDoorSecurityMap(user.id, user.username);
  return {
    userState,
    target,
    security: normalizeDoorSecurity(target.device, doorSecurityMap[target.device.id])
  };
}

async function persistDoorState(user, room, device, security) {
  device.locked = security.lockStatus !== 'unlocked';
  device.power = security.lockStatus === 'unlocked';
  device.lockStatus = security.lockStatus;
  device.doorStatus = security.doorStatus;
  device.cameraStatus = security.cameraStatus;
  device.visitorType = security.visitorType;
  device.visitorName = security.visitorName;
  device.riskLevel = security.riskLevel;
  device.visitorVerified = security.visitorVerified;
  device.failedAttempts = security.failedAttempts;
  device.lockUntil = security.lockUntil;
  device.lastUnlockTime = security.lastUnlockTime;
  await saveDoorSecurity(user.id, user.username, device.id, security);
  await saveDevice(user, room.id, device);
  return mergeDoorSecurity(device, security);
}

function scheduleDoorAutomation(user, room, device, security) {
  clearDoorAutomation(device.id);
  const openTimer = setTimeout(async () => {
    try {
      const latest = await getDoorTarget(user, device.id);
      if (latest.error) {
        return;
      }
      const openedSecurity = normalizeDoorSecurity(latest.target.device, latest.security);
      openedSecurity.lockStatus = 'unlocked';
      openedSecurity.doorStatus = 'opened';
      openedSecurity.cameraStatus = openedSecurity.visitorType === 'stranger' ? 'alert' : 'active';
      await persistDoorState(user, latest.target.room, latest.target.device, openedSecurity);
      await addLog(user.id, user.username, 'DOOR_OPEN', latest.target.device.name, '门体已打开');
    } catch (error) {
      console.error('door open automation failed', error);
    }
  }, DOOR_OPEN_DELAY_MS);

  const relockTimer = setTimeout(async () => {
    try {
      const latest = await getDoorTarget(user, device.id);
      if (latest.error) {
        return;
      }
      const lockedSecurity = normalizeDoorSecurity(latest.target.device, latest.security);
      lockedSecurity.lockStatus = 'locked';
      lockedSecurity.doorStatus = 'closed';
      lockedSecurity.failedAttempts = 0;
      lockedSecurity.lockUntil = null;
      await persistDoorState(user, latest.target.room, latest.target.device, lockedSecurity);
      await addLog(user.id, user.username, 'DOOR_AUTO_LOCK', latest.target.device.name, '门禁已自动回锁');
      clearDoorAutomation(device.id);
    } catch (error) {
      console.error('door relock automation failed', error);
    }
  }, DOOR_AUTO_LOCK_MS);

  doorAutomationTimers.set(device.id, { openTimer, relockTimer });
}

async function unlockDoorForUser(user, deviceId, pin) {
  const doorTarget = await getDoorTarget(user, deviceId);
  if (doorTarget.error) {
    return { error: doorTarget.error };
  }

  const { target, security } = doorTarget;
  const nowTime = Date.now();
  const lockUntilTime = security.lockUntil ? new Date(security.lockUntil).getTime() : 0;
  if (lockUntilTime > nowTime) {
    const seconds = Math.max(1, Math.ceil((lockUntilTime - nowTime) / 1000));
      return { error: `door temporarily locked, retry in ${seconds}s` };
  }

  if (DOOR_REQUIRE_PIN && `${pin || ''}` !== DOOR_SECURITY_PIN) {
    security.failedAttempts = (security.failedAttempts || 0) + 1;
    security.visitorVerified = false;
    if (security.failedAttempts >= 3) {
      security.lockUntil = new Date(nowTime + DOOR_PIN_LOCK_MS).toISOString();
    } else {
      security.lockUntil = null;
    }
    await persistDoorState(user, target.room, target.device, security);
    await addLog(user.id, user.username, 'DOOR_PIN_FAIL', target.device.name, 'PIN 验证失败');
    return {
      error: security.lockUntil ? 'pin failed 3 times, door locked for 60s' : 'invalid security pin'
    };
  }

  security.failedAttempts = 0;
  security.lockUntil = null;
  security.visitorVerified = true;
  security.lockStatus = 'unlocked';
  security.doorStatus = 'closed';
  security.lastUnlockTime = now();
  security.cameraStatus = security.visitorType === 'none' ? 'idle' : security.visitorType === 'stranger' ? 'alert' : 'active';
  const device = await persistDoorState(user, target.room, target.device, security);
  await addLog(user.id, user.username, 'DOOR_UNLOCK', target.device.name, '已发起远程解锁');
  if (security.riskLevel === 'high') {
    await addLog(user.id, user.username, 'DOOR_RISK', target.device.name, '检测到高风险访客');
  }
  scheduleDoorAutomation(user, target.room, target.device, security);
  return { success: true, device };
}

async function lockDoorForUser(user, deviceId, detail) {
  const doorTarget = await getDoorTarget(user, deviceId);
  if (doorTarget.error) {
    return { error: doorTarget.error };
  }
  const { target, security } = doorTarget;
  clearDoorAutomation(target.device.id);
  security.lockStatus = 'locked';
  security.doorStatus = 'closed';
  security.failedAttempts = 0;
  security.lockUntil = null;
  const device = await persistDoorState(user, target.room, target.device, security);
  await addLog(user.id, user.username, 'DOOR_LOCK', target.device.name, detail || '入户门已手动上锁');
  return { success: true, device };
}

function extensionForMimeType(mimeType, fileName) {
  const safeName = `${fileName || ''}`.toLowerCase();
  if (safeName.endsWith('.webm') || mimeType === 'video/webm') {
    return '.webm';
  }
  if (safeName.endsWith('.mov') || mimeType === 'video/quicktime') {
    return '.mov';
  }
  return '.mp4';
}

async function uploadDoorCameraForUser(user, deviceId, payload) {
  const doorTarget = await getDoorTarget(user, deviceId);
  if (doorTarget.error) {
    return { error: doorTarget.error };
  }

  const base64 = `${payload.base64 || ''}`.trim();
  const mimeType = `${payload.mimeType || ''}`.trim().toLowerCase();
  const fileName = `${payload.fileName || ''}`.trim();
  if (!base64) {
    return { error: 'video content required' };
  }
  if (!['video/mp4', 'video/webm', 'video/quicktime'].includes(mimeType)) {
    return { error: 'unsupported video type' };
  }

  let buffer;
  try {
    buffer = Buffer.from(base64, 'base64');
  } catch (error) {
    return { error: 'invalid video data' };
  }
  if (!buffer.length) {
    return { error: 'invalid video data' };
  }
  if (buffer.length > 20 * 1024 * 1024) {
    return { error: 'video too large' };
  }

  const uploadDir = path.join(UPLOADS_ROOT, 'doorcam');
  ensureDir(uploadDir);
  const extension = extensionForMimeType(mimeType, fileName);
  const storedName = `${user.username}_${deviceId}_${Date.now()}${extension}`;
  const absolutePath = path.join(uploadDir, storedName);
  fs.writeFileSync(absolutePath, buffer);

  const record = await saveDoorCameraRecord(user, deviceId, {
    deviceId,
    videoUrl: `/uploads/doorcam/${storedName}`,
    coverUrl: `/uploads/doorcam/${storedName}`,
    capturedAt: now(),
    durationSec: null,
    cameraStatus: doorTarget.security.riskLevel === 'high' ? 'alert' : 'normal',
    notes: fileName || 'door camera upload'
  });
  await addLog(user.id, user.username, 'DOOR_CAMERA_UPLOAD', doorTarget.target.device.name, '门前视频已上传并同步到网页');
  return { success: true, camera: record };
}

async function updateDoorVisitorForUser(user, deviceId, visitorType) {
  const doorTarget = await getDoorTarget(user, deviceId);
  if (doorTarget.error) {
    return { error: doorTarget.error };
  }
  const { target, security } = doorTarget;
  const visitor = visitorPreset(visitorType);
  security.visitorType = visitor.visitorType;
  security.visitorName = visitor.visitorName;
  security.riskLevel = visitor.riskLevel;
  security.visitorVerified = visitor.visitorVerified;
  security.cameraStatus = visitor.cameraStatus;
  const device = await persistDoorState(user, target.room, target.device, security);
  await addLog(user.id, user.username, 'VISITOR_UPDATE', target.device.name, '访客已更新为 ' + visitor.visitorName);
  return { success: true, device };
}

async function controlTypeForUser(user, type, power, roomName) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user not found' };
  }

  const affectedRooms = roomName
    ? userState.rooms.filter((room) => isSameRoomName(room.name, roomName))
    : userState.rooms;

  for (const room of affectedRooms) {
    for (const device of room.devices) {
      if (device.type !== type) {
        continue;
      }
      if (type === 'door') {
        device.locked = !power;
        device.power = power;
        const doorSecurityMap = await getDoorSecurityMap(user.id, user.username);
        const security = normalizeDoorSecurity(device, doorSecurityMap[device.id]);
        security.lockStatus = power ? 'unlocked' : 'locked';
        security.doorStatus = power ? 'opened' : 'closed';
        security.failedAttempts = 0;
        security.lockUntil = null;
        await saveDoorSecurity(user.id, user.username, device.id, security);
      } else if (type === 'light') {
        const nextBrightness = typeof device.brightness === 'number' && device.brightness > 0 ? device.brightness : 72;
        device.power = power;
        device.brightness = power ? nextBrightness : 0;
      } else {
        device.power = power;
      }
      await saveDevice(user, room.id, device);
    }
  }

  await addLog(
    user.id,
    user.username,
    'TYPE_CONTROL',
    roomName ? `${roomName}-${type}` : `${type}`,
    power ? 'type control on' : 'type control off'
  );
  return { success: true };
}

async function applySceneForUser(user, scene) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user not found' };
  }
  const config = await getSceneConfig(user.id, user.username);
  const homeTypes = config.homeTypes || [];

  for (const room of userState.rooms) {
    for (const device of room.devices) {
      if (scene === 'away') {
        if (device.type === 'door') {
          device.locked = true;
          device.power = false;
          const doorSecurityMap = await getDoorSecurityMap(user.id, user.username);
          const security = normalizeDoorSecurity(device, doorSecurityMap[device.id]);
          security.lockStatus = 'locked';
          security.doorStatus = 'closed';
          security.failedAttempts = 0;
          security.lockUntil = null;
          await saveDoorSecurity(user.id, user.username, device.id, security);
        } else if (device.type === 'light') {
          device.power = false;
          device.brightness = 0;
        } else {
          device.power = false;
        }
      } else {
        if (device.type === 'door') {
          const enableDoor = homeTypes.includes('door');
          device.locked = !enableDoor;
          device.power = enableDoor;
          const doorSecurityMap = await getDoorSecurityMap(user.id, user.username);
          const security = normalizeDoorSecurity(device, doorSecurityMap[device.id]);
          security.lockStatus = enableDoor ? 'unlocked' : 'locked';
          security.doorStatus = enableDoor ? 'opened' : 'closed';
          security.failedAttempts = 0;
          security.lockUntil = null;
          await saveDoorSecurity(user.id, user.username, device.id, security);
        } else if (device.type === 'light') {
          const enableLight = homeTypes.includes('light');
          const nextBrightness = typeof device.brightness === 'number' && device.brightness > 0 ? device.brightness : 72;
          device.power = enableLight;
          device.brightness = enableLight ? nextBrightness : 0;
        } else {
          device.power = homeTypes.includes(device.type);
        }
      }
      await saveDevice(user, room.id, device);
    }
  }

  await saveCurrentMode(user.id, user.username, scene);
  await addLog(user.id, user.username, 'SCENE_APPLY', scene === 'away' ? 'away mode' : 'home mode', 'scene applied');
  return { success: true };
}

async function applySmartSceneForUser(user, scene) {
  const userState = await buildStateForUser(user.username);
  if (!userState) {
    return { error: 'user_not_found' };
  }

  const config = alignSceneConfigToRooms(await getSceneConfig(user.id, user.username), userState.rooms);
  const sceneModes = [config.home, config.away, config.sleep, config.energy, ...(config.customModes || [])];
  const activePreset = sceneModes.find((item) => item && item.key === scene) || config.home;
  const presetDevices = Array.isArray(activePreset.devices) ? activePreset.devices : [];
  const presetMap = new Map(presetDevices.map((item) => [item.deviceId, item]));
  const doorSecurityMap = await getDoorSecurityMap(user.id, user.username);

  for (const room of userState.rooms) {
    for (const device of room.devices) {
      const preset = presetMap.get(device.id);
      const type = normalizeType(device.type);
      if (!preset) {
        continue;
      }
      if (type === 'door') {
        const enableDoor = preset.enabled === true;
        device.locked = enableDoor ? preset.locked !== false : device.locked !== false;
        device.power = false;
        const security = normalizeDoorSecurity(device, doorSecurityMap[device.id]);
        security.lockStatus = device.locked === false ? 'unlocked' : 'locked';
        security.doorStatus = device.locked === false ? 'opened' : 'closed';
        security.failedAttempts = 0;
        security.lockUntil = null;
        await saveDoorSecurity(user.id, user.username, device.id, security);
      } else if (type === 'light' || type === 'curtain') {
        const enableLight = preset.enabled === true;
        const brightness = typeof preset.brightness === 'number'
          ? preset.brightness
          : (enableLight ? 72 : 0);
        device.power = enableLight && brightness > 0;
        device.brightness = device.power ? brightness : 0;
        if (type === 'curtain') {
          device.mode = preset.mode || device.mode || '自动';
        }
      } else if (type === 'air') {
        const enableAir = preset.enabled === true;
        device.power = enableAir;
        if (enableAir) {
          device.temperature = typeof preset.temperature === 'number' ? preset.temperature : 26;
          device.mode = preset.mode || '制冷';
        }
      }

      await saveDevice(user, room.id, device);
    }
  }

  await saveCurrentMode(user.id, user.username, activePreset.key);
  await addLog(user.id, user.username, 'SCENE_APPLY', activePreset.label || 'scene', 'scene applied');
  return { success: true };
}

function sendJson(res, statusCode, data) {
  const body = JSON.stringify(data);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  res.end(body);
}

function sendHtml(res, fileName) {
  const filePath = path.join(__dirname, 'public', fileName);
  const html = fs.readFileSync(filePath, 'utf8');
  res.writeHead(200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-cache'
  });
  res.end(html);
}

function staticCacheControl(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (['.js', '.mjs', '.css', '.png', '.jpg', '.jpeg', '.gif', '.webp'].includes(ext)) {
    return 'public, max-age=604800';
  }
  if (['.mp4', '.webm', '.mov', '.mp3', '.wav', '.ogg'].includes(ext)) {
    return 'public, max-age=86400';
  }
  return 'public, max-age=3600';
}

function parseRange(rangeHeader, size) {
  const match = /^bytes=(\d*)-(\d*)$/.exec(`${rangeHeader || ''}`.trim());
  if (!match) return null;

  let start = match[1] ? Number(match[1]) : 0;
  let end = match[2] ? Number(match[2]) : size - 1;
  if (!match[1] && match[2]) {
    const suffixLength = Number(match[2]);
    start = Math.max(size - suffixLength, 0);
    end = size - 1;
  }
  if (!Number.isFinite(start) || !Number.isFinite(end) || start < 0 || end < start || start >= size) {
    return null;
  }
  return { start, end: Math.min(end, size - 1) };
}

function sendFile(res, filePath, method, rangeHeader) {
  const stat = fs.statSync(filePath);
  const mimeType = getMimeType(filePath);
  const headers = {
    'Content-Type': mimeType,
    'Content-Length': stat.size,
    'Cache-Control': staticCacheControl(filePath),
    'Accept-Ranges': 'bytes'
  };

  const supportsRange = /^(video|audio)\//.test(mimeType);
  const range = supportsRange ? parseRange(rangeHeader, stat.size) : null;
  if (rangeHeader && supportsRange && !range) {
    res.writeHead(416, { 'Content-Range': `bytes */${stat.size}` });
    res.end();
    return;
  }

  if (range) {
    const chunkSize = range.end - range.start + 1;
    res.writeHead(206, {
      ...headers,
      'Content-Length': chunkSize,
      'Content-Range': `bytes ${range.start}-${range.end}/${stat.size}`
    });
    if (method === 'HEAD') {
      res.end();
      return;
    }
    fs.createReadStream(filePath, { start: range.start, end: range.end }).pipe(res);
    return;
  }

  res.writeHead(200, headers);
  if (method === 'HEAD') {
    res.end();
    return;
  }
  fs.createReadStream(filePath).pipe(res);
}

function sendPublicAsset(res, pathname, prefix, method, rangeHeader) {
  const relativePath = decodeURIComponent(pathname.replace(prefix, ''));
  const safePath = path.normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
  const filePath = path.resolve(PUBLIC_ROOT, prefix.replace(/^\/|\/$/g, ''), safePath);
  const assetRootResolved = path.resolve(PUBLIC_ROOT, prefix.replace(/^\/|\/$/g, ''));
  if (!filePath.startsWith(assetRootResolved) || !fs.existsSync(filePath)) {
    sendJson(res, 404, { success: false, message: 'asset not found' });
    return;
  }
  sendFile(res, filePath, method, rangeHeader);
}

function readBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', (chunk) => {
      body += chunk;
    });
    req.on('end', () => {
      resolve(body);
    });
  });
}

async function readJson(req) {
  const rawBody = await readBody(req);
  if (!rawBody) {
    return {};
  }
  return JSON.parse(rawBody);
}

function userFromQuery(url) {
  try {
    const parsed = new URL(url, 'http://127.0.0.1');
    return parsed.searchParams.get('username') || USERNAME;
  } catch (error) {
    return USERNAME;
  }
}

function normalizeAiChatUrl(rawUrl) {
  const value = `${rawUrl || ''}`.trim();
  if (!value) {
    return 'https://api.openai.com/v1/chat/completions';
  }
  if (value.endsWith('/chat/completions')) {
    return value;
  }
  if (value.endsWith('/')) {
    return value + 'chat/completions';
  }
  return value + '/chat/completions';
}

function sanitizeJsonBlock(content) {
  const raw = `${content || ''}`.trim();
  if (!raw) {
    return raw;
  }
  const fenced = raw.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  return fenced ? fenced[1].trim() : raw;
}

function normalizeHousekeeperIntentLabel(intent) {
  if (intent === 'elder_comfort') {
    return '老人舒适模式';
  }
  if (intent === 'sleep_mode') {
    return '睡眠模式';
  }
  if (intent === 'away_safe') {
    return '离家安全模式';
  }
  if (intent === 'energy_save') {
    return '节能模式';
  }
  if (intent === 'music_clean') {
    return '音乐清扫模式';
  }
  return '智能调度模式';
}

function containsAnyKeyword(text, lower, keywords) {
  for (const keyword of keywords) {
    if (!keyword) {
      continue;
    }
    const target = /[A-Za-z]/.test(keyword) ? lower : text;
    const probe = /[A-Za-z]/.test(keyword) ? keyword.toLowerCase() : keyword;
    if (target.includes(probe)) {
      return true;
    }
  }
  return false;
}

function matchHousekeeperIntent(userInput) {
  const text = `${userInput || ''}`.trim();
  const lower = text.toLowerCase();
  const musicKeywords = ['音乐', '播放', '听歌', '放歌', '播歌', '歌曲', '歌单', 'bgm', 'music', 'play', 'song', 'audio'];
  const cleanKeywords = ['扫地', '打扫', '清扫', '清洁', '搞卫生', '做卫生', '卫生', '拖地', '吸尘', '机器人', '扫地机', 'vacuum', 'clean', 'sweep', 'robot'];
  const elderKeywords = ['老人', '长辈', '70岁', '舒适', 'elder', 'old', 'senior', 'comfort'];
  const sleepKeywords = ['睡', '休息', '夜间', '睡眠', '入睡', '晚安', 'sleep', 'rest', 'night', 'bedtime'];
  const awayKeywords = ['出门', '离家', '外出', '安全', '防盗', 'away', 'leave', 'out', 'safe', 'security'];
  const energyKeywords = ['省电', '节能', '省能', '低耗', 'save power', 'energy', 'eco'];

  if (containsAnyKeyword(text, lower, musicKeywords) && containsAnyKeyword(text, lower, cleanKeywords)) {
    return 'music_clean';
  }
  if (containsAnyKeyword(text, lower, elderKeywords)) {
    return 'elder_comfort';
  }
  if (containsAnyKeyword(text, lower, sleepKeywords)) {
    return 'sleep_mode';
  }
  if (containsAnyKeyword(text, lower, awayKeywords)) {
    return 'away_safe';
  }
  if (containsAnyKeyword(text, lower, energyKeywords)) {
    return 'energy_save';
  }
  return '';
}

function detectHousekeeperIntent(userInput) {
  return matchHousekeeperIntent(userInput) || 'elder_comfort';
}

function collectDevicesByType(rooms, type) {
  const result = [];
  for (const room of rooms || []) {
    for (const device of room.devices || []) {
      if (device.type === type) {
        result.push({ room, device });
      }
    }
  }
  return result;
}

function buildRuleBasedHousekeeperPlan(state, userInput) {
  const intent = detectHousekeeperIntent(userInput);
  const lights = collectDevicesByType(state.rooms, 'light');
  const curtains = collectDevicesByType(state.rooms, 'curtain');
  const airs = collectDevicesByType(state.rooms, 'air');
  const doors = collectDevicesByType(state.rooms, 'door');
  const speakers = collectDevicesByType(state.rooms, 'speaker');
  const robots = collectDevicesByType(state.rooms, 'robot');
  const environment = state.environment || defaultEnvironmentConfig();
  let actions = [];

  if (intent === 'music_clean') {
    actions = [
      {
        device: 'speaker',
        action: 'play',
        params: { power: speakers.length > 0 ? 'on' : 'off', musicPlaying: speakers.length > 0 },
        reason: '播放轻音乐，提升居家氛围'
      },
      {
        device: 'robot',
        action: 'start',
        params: { power: robots.length > 0 ? 'on' : 'off', activityArea: robots[0] ? (robots[0].device.activityArea || '客厅') : '客厅' },
        reason: '启动扫地机器人，开始清扫卫生'
      }
    ];
  } else if (intent === 'sleep_mode') {
    actions = [
      {
        device: 'light',
        action: 'set',
        params: { power: lights.length > 0 ? 'on' : 'off', brightness: lights.length > 0 ? 20 : 0 },
        reason: 'reduce glare for rest'
      },
      {
        device: 'curtain',
        action: 'set',
        params: { power: curtains.length > 0 ? 'on' : 'off', brightness: curtains.length > 0 ? 0 : 0, mode: 'sleep' },
        reason: '休息时关闭窗帘，减少外部光线干扰'
      },
      {
        device: 'airConditioner',
        action: 'set',
        params: { power: airs.length > 0 ? 'on' : 'off', targetTemp: 25, mode: 'sleep', fanSpeed: 'low' },
        reason: '维持更安静的睡眠环境'
      },
      {
        device: 'doorLock',
        action: 'lock',
        params: { locked: true },
        reason: '保障夜间安全'
      }
    ];
  } else if (intent === 'away_safe') {
    actions = [
      {
        device: 'light',
        action: 'set',
        params: { power: 'off', brightness: 0 },
        reason: 'turn off all lights while away'
      },
      {
        device: 'curtain',
        action: 'set',
        params: { power: curtains.length > 0 ? 'on' : 'off', brightness: 0, mode: 'manual' },
        reason: 'close curtains for privacy while away'
      },
      {
        device: 'airConditioner',
        action: 'set',
        params: { power: 'off', targetTemp: airs[0] && airs[0].device.temperature ? airs[0].device.temperature : 28, mode: 'cool', fanSpeed: 'low' },
        reason: '离家场景优先节能'
      },
      {
        device: 'doorLock',
        action: 'lock',
        params: { locked: true },
        reason: '执行一键上锁，保持入户安全'
      }
    ];
  } else if (intent === 'energy_save') {
    actions = [
      {
        device: 'light',
        action: 'set',
        params: { power: lights.length > 0 ? 'on' : 'off', brightness: lights.length > 0 ? 35 : 0 },
        reason: 'keep only essential lighting'
      },
      {
        device: 'curtain',
        action: 'set',
        params: { power: curtains.length > 0 ? 'on' : 'off', brightness: curtains.length > 0 ? 40 : 0, mode: 'energy' },
        reason: 'reduce solar heat through partial curtain closure'
      },
      {
        device: 'airConditioner',
        action: 'set',
        params: { power: airs.length > 0 ? 'on' : 'off', targetTemp: environment.temperature >= 29 ? 27 : 26, mode: 'dry', fanSpeed: 'low' },
        reason: '避免过度制冷造成额外耗电'
      },
      {
        device: 'doorLock',
        action: 'lock',
        params: { locked: true },
        reason: 'security remains enabled in energy mode'
      }
    ];
  } else {
    actions = [
      {
        device: 'light',
        action: 'set',
        params: { power: lights.length > 0 ? 'on' : 'off', brightness: lights.length > 0 ? 70 : 0 },
        reason: '为老人提供柔和照明'
      },
      {
        device: 'curtain',
        action: 'set',
        params: { power: curtains.length > 0 ? 'on' : 'off', brightness: curtains.length > 0 ? 60 : 0, mode: 'auto' },
        reason: 'reduce harsh sunlight and keep soft daylight'
      },
      {
        device: 'airConditioner',
        action: 'set',
        params: { power: airs.length > 0 ? 'on' : 'off', targetTemp: 26, mode: 'cool', fanSpeed: 'low' },
        reason: 'adjust to a comfortable indoor climate'
      },
      {
        device: 'doorLock',
        action: 'lock',
        params: { locked: true },
        reason: 'keep entrance door secure'
      }
    ];
  }

  return {
    intent,
    intentLabel: normalizeHousekeeperIntentLabel(intent),
    summary: `已为${normalizeHousekeeperIntentLabel(intent)}生成全屋调度方案`,
    needConfirm: true,
    messageToUser: `已生成${normalizeHousekeeperIntentLabel(intent)}，是否一键执行？`,
    actions
  };
}

function normalizeHousekeeperPower(value, fallback) {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'number') {
    return value > 0;
  }
  if (typeof value === 'string') {
    const lower = value.toLowerCase();
    if (['on', 'open', 'start', 'play', 'playing', 'true'].includes(lower)) {
      return true;
    }
    if (['off', 'close', 'stop', 'pause', 'false'].includes(lower)) {
      return false;
    }
  }
  return fallback;
}

function normalizeHousekeeperNumber(value, fallback) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  return fallback;
}

function normalizeHousekeeperMode(mode) {
  const value = `${mode || ''}`.trim();
  const lower = value.toLowerCase();
  if (!value) {
    return '';
  }
  if (lower === 'cool' || value === '鍒跺喎' || value === '制冷') {
    return '制冷';
  }
  if (lower === 'heat' || value === '鍒剁儹' || value === '制热') {
    return '制热';
  }
  if (lower === 'dry' || value === '闄ゆ箍') {
    return '除湿';
  }
  if (lower === 'fan' || value === '閫侀') {
    return '送风';
  }
  if (lower === 'sleep' || value === '鐫＄湢' || value === '睡眠') {
    return '睡眠';
  }
  if (lower === 'auto' || value === '鑷姩' || value === '自动') {
    return '自动';
  }
  if (lower === 'manual' || value === '鎵嬪姩' || value === '手动') {
    return '手动';
  }
  if (lower === 'energy' || value === '鑺傝兘' || value === '节能') {
    return '节能';
  }
  return value;
}

function housekeeperActionTitle(deviceType) {
  if (deviceType === 'light') {
    return '灯光';
  }
  if (deviceType === 'curtain') {
    return '窗帘';
  }
  if (deviceType === 'air') {
    return '空调';
  }
  if (deviceType === 'door') {
    return '门禁';
  }
  if (deviceType === 'speaker') {
    return '音箱';
  }
  if (deviceType === 'robot') {
    return '扫地机器人';
  }
  return '设备';
}

function housekeeperActionReason(deviceType, action) {
  if (typeof action.reason === 'string' && action.reason.trim()) {
    return action.reason.trim();
  }
  if (deviceType === 'speaker') {
    return '根据当前需求控制音箱播放状态';
  }
  if (deviceType === 'robot') {
    return '根据当前需求控制扫地机器人清扫';
  }
  if (deviceType === 'door') {
    return '保持门禁安全状态';
  }
  return '根据当前场景自动调整设备';
}

function housekeeperActionDetail(action) {
  if (typeof action.detail === 'string' && action.detail.trim()) {
    return action.detail.trim();
  }
  if (action.deviceType === 'light') {
    if (action.power) {
      return `开启灯光${typeof action.brightness === 'number' ? `，亮度 ${action.brightness}%` : ''}`;
    }
    return '关闭灯光';
  }
  if (action.deviceType === 'curtain') {
    if (action.power) {
      return `开启窗帘，开合度 ${typeof action.brightness === 'number' ? action.brightness : 60}%${action.mode ? ` · ${action.mode}` : ''}`;
    }
    return '关闭窗帘';
  }
  if (action.deviceType === 'air') {
    if (action.power) {
      return `开启空调${typeof action.temperature === 'number' ? `，目标温度 ${action.temperature}°C` : ''}${action.mode ? ` · ${action.mode}` : ''}`;
    }
    return '关闭空调';
  }
  if (action.deviceType === 'door') {
    return action.locked === true ? '保持门禁上锁' : '保持当前门禁状态';
  }
  if (action.deviceType === 'speaker') {
    return action.power ? '播放音乐' : '暂停音乐';
  }
  if (action.deviceType === 'robot') {
    return action.power ? '启动扫地机器人，开始清扫卫生' : '停止扫地机器人';
  }
  return '执行设备联动';
}

function normalizeHousekeeperAction(rawAction, index) {
  const params = rawAction && typeof rawAction.params === 'object' && rawAction.params !== null ? rawAction.params : {};
  const deviceType = normalizeType(rawAction.deviceType || rawAction.device || rawAction.type || rawAction.title || '');
  if (!['light', 'curtain', 'air', 'door', 'speaker', 'robot'].includes(deviceType)) {
    return null;
  }

  const actionText = `${rawAction.action || ''}`.trim();
  const actionName = actionText.toLowerCase();
  let power = normalizeHousekeeperPower(rawAction.power, undefined);
  if (params.power !== undefined) {
    power = normalizeHousekeeperPower(params.power, power);
  }
  if (deviceType === 'speaker' && params.musicPlaying !== undefined) {
    power = normalizeHousekeeperPower(params.musicPlaying, power);
  }
  if (deviceType === 'speaker' && power === undefined) {
    if (actionName.includes('pause') || actionName.includes('stop') || actionText.includes('暂停') || actionText.includes('停止')) {
      power = false;
    } else if (actionName.includes('play') || actionName === 'set' || actionText.includes('播放') || actionText.includes('开启')) {
      power = true;
    }
  }
  if (deviceType === 'robot' && power === undefined) {
    if (actionName.includes('stop') || actionText.includes('暂停') || actionText.includes('停止')) {
      power = false;
    } else if (actionName.includes('start') || actionName.includes('clean') || actionName === 'set'
      || actionText.includes('启动') || actionText.includes('打扫') || actionText.includes('清扫')) {
      power = true;
    }
  }

  let brightness = normalizeHousekeeperNumber(rawAction.brightness, undefined);
  if (brightness === undefined) {
    brightness = normalizeHousekeeperNumber(params.brightness, undefined);
  }
  if (brightness === undefined) {
    brightness = normalizeHousekeeperNumber(params.openness, undefined);
  }

  let temperature = normalizeHousekeeperNumber(rawAction.temperature, undefined);
  if (temperature === undefined) {
    temperature = normalizeHousekeeperNumber(params.targetTemp, undefined);
  }
  if (temperature === undefined) {
    temperature = normalizeHousekeeperNumber(params.temperature, undefined);
  }

  const mode = normalizeHousekeeperMode(rawAction.mode || params.mode || '');
  let locked = typeof rawAction.locked === 'boolean' ? rawAction.locked : undefined;
  if (typeof params.locked === 'boolean') {
    locked = params.locked;
  }
  if (deviceType === 'door' && locked === undefined && actionName === 'lock') {
    locked = true;
  }

  if ((deviceType === 'light' || deviceType === 'curtain') && power === undefined && typeof brightness === 'number') {
    power = brightness > 0;
  }

  const action = {
    key: rawAction.key || `${deviceType}_${index + 1}`,
    deviceType,
    title: rawAction.title || housekeeperActionTitle(deviceType),
    detail: '',
    reason: '',
    power: power === undefined ? false : power,
    brightness,
    temperature,
    mode,
    locked
  };
  action.detail = housekeeperActionDetail(action);
  action.reason = housekeeperActionReason(deviceType, rawAction);
  return action;
}

function normalizeHousekeeperPlan(rawPlan, userInput) {
  const plan = rawPlan && typeof rawPlan === 'object' ? rawPlan : {};
  const intent = typeof plan.intent === 'string' && plan.intent.trim()
    ? plan.intent.trim()
    : detectHousekeeperIntent(userInput);
  const actions = Array.isArray(plan.actions)
    ? plan.actions
      .map((action, index) => normalizeHousekeeperAction(action || {}, index))
      .filter(Boolean)
    : [];
  const intentLabel = typeof plan.intentLabel === 'string' && plan.intentLabel.trim()
    ? plan.intentLabel.trim()
    : normalizeHousekeeperIntentLabel(intent);
  return {
    intent,
    intentLabel,
    summary: typeof plan.summary === 'string' && plan.summary.trim()
      ? plan.summary.trim()
      : `已为${intentLabel}生成全屋调度方案`,
    needConfirm: plan.needConfirm !== false,
    messageToUser: typeof plan.messageToUser === 'string' && plan.messageToUser.trim()
      ? plan.messageToUser.trim()
      : `已生成${intentLabel}，是否一键执行？`,
    actions
  };
}

async function callAiPlanner(userInput, state) {
  if (!AI_API_KEY) {
    return null;
  }
  const systemPrompt = [
    'You are the smart home housekeeper AI. Generate executable smart-home JSON only.',
    'Controllable devices: light, curtain, airConditioner, doorLock, speaker, robot, sensor.',
    'light supports power and brightness.',
    'curtain supports power, brightness, and mode. brightness means openness.',
    'airConditioner supports power, targetTemp, mode, fanSpeed.',
    'doorLock only allows lock, never unlock.',
    'speaker supports musicPlaying and power. Use it for play or pause music.',
    'robot supports power and activityArea. Use it for start or stop cleaning.',
    'sensor is read-only.',
    'Safety rules:',
    '1. Never unlock the entrance door automatically.',
    '2. Air conditioner targetTemp must stay between 24 and 28.',
    '3. Output JSON only, no extra explanation.',
    'JSON fields: intent, intentLabel, summary, needConfirm, messageToUser, actions.',
    'Action fields: device, action, params, reason.'
  ].join('\n');

  const response = await fetch(normalizeAiChatUrl(AI_BASE_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${AI_API_KEY}`
    },
    body: JSON.stringify({
      model: AI_MODEL,
      temperature: 0,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: systemPrompt },
        {
          role: 'user',
          content: JSON.stringify({
            userInput,
            homeState: {
              temperature: state.environment ? state.environment.temperature : 26,
              humidity: state.environment ? state.environment.humidity : 48,
              mode: state.mode,
              rooms: state.rooms
            }
          })
        }
      ]
    })
  });

  if (!response.ok) {
    throw new Error(`AI request failed: ${response.status}`);
  }
  const data = await response.json();
  const content = data && data.choices && data.choices[0] && data.choices[0].message
    ? data.choices[0].message.content
    : '';
  if (!content) {
    throw new Error('AI response content empty');
  }
  return JSON.parse(sanitizeJsonBlock(content));
}

async function createHousekeeperPlanForUser(user, userInput) {
  const state = await buildStateForUser(user.username);
  if (!state) {
    return { error: 'user not found' };
  }
  const matchedIntent = matchHousekeeperIntent(userInput);
  if (matchedIntent) {
    const plan = normalizeHousekeeperPlan(buildRuleBasedHousekeeperPlan(state, userInput), userInput);
    return { success: true, plan, state };
  }
  let plan = null;
  try {
    plan = await callAiPlanner(userInput, state);
  } catch (error) {
    console.error('ai planner fallback to rules', error.message);
  }
  if (!plan) {
    plan = buildRuleBasedHousekeeperPlan(state, userInput);
  }
  plan = normalizeHousekeeperPlan(plan, userInput);
  return { success: true, plan, state };
}

async function executeHousekeeperPlanForUser(user, plan) {
  const resultLines = [];
  const state = await buildStateForUser(user.username);
  if (!state) {
    return { error: 'user not found' };
  }
  const normalizedPlan = normalizeHousekeeperPlan(plan, '');
  const actions = normalizedPlan.actions;

  for (const action of actions) {
    if (action.deviceType === 'light') {
      const lights = collectDevicesByType(state.rooms, 'light');
      for (const item of lights) {
        await updateDeviceForUser(user, {
          deviceId: item.device.id,
          power: action.power === true,
          brightness: typeof action.brightness === 'number' ? action.brightness : 0
        }, 'light');
      }
      resultLines.push(`灯光：${action.power ? '已开启' : '已关闭'}${typeof action.brightness === 'number' && action.power ? `，亮度 ${action.brightness}%` : ''}`);
      continue;
    }

    if (action.deviceType === 'curtain') {
      const curtains = collectDevicesByType(state.rooms, 'curtain');
      for (const item of curtains) {
        await updateDeviceForUser(user, {
          deviceId: item.device.id,
          power: action.power === true,
          brightness: typeof action.brightness === 'number' ? action.brightness : 0,
          mode: action.mode || '自动'
        }, 'curtain');
      }
      resultLines.push(`窗帘：${action.power ? '已开启' : '已关闭'}${typeof action.brightness === 'number' ? `，开合度 ${action.brightness}%` : ''}${action.mode ? ` · ${action.mode}` : ''}`);
      continue;
    }

    if (action.deviceType === 'air') {
      const airs = collectDevicesByType(state.rooms, 'air');
      for (const item of airs) {
        await updateDeviceForUser(user, {
          deviceId: item.device.id,
          power: action.power === true,
          temperature: typeof action.temperature === 'number' ? action.temperature : 26,
          mode: action.mode || '制冷'
        }, 'air');
      }
      resultLines.push(`空调：${action.power ? '已开启' : '已关闭'}${typeof action.temperature === 'number' && action.power ? `，目标温度 ${action.temperature}°C` : ''}${action.mode ? ` · ${action.mode}` : ''}`);
      continue;
    }

    if (action.deviceType === 'door') {
      const doors = collectDevicesByType(state.rooms, 'door');
      if (action.locked === true) {
        for (const item of doors) {
          await lockDoorForUser(user, item.device.id, 'AI requested door lock');
        }
      }
      resultLines.push(`门禁：${action.locked === true ? '已上锁' : '保持当前状态'}`);
      continue;
    }

    if (action.deviceType === 'speaker') {
      const speakers = collectDevicesByType(state.rooms, 'speaker');
      for (const item of speakers) {
        await updateDeviceForUser(user, {
          deviceId: item.device.id,
          type: 'speaker',
          power: true,
          listening: true,
          musicPlaying: action.power === true,
          musicTrackId: item.device.musicTrackId || 'demo-tone',
          lastCommand: action.power === true ? 'AI 管家自动播放音乐' : 'AI 管家暂停音乐',
          lastBroadcast: action.power === true
            ? `正在播放：${item.device.musicTitle || '智能音箱演示音乐'}`
            : '音乐已暂停'
        }, 'generic');
      }
      resultLines.push(`音箱：${action.power === true ? '开始播放音乐' : '已暂停音乐'}`);
      continue;
    }

    if (action.deviceType === 'robot') {
      const robots = collectDevicesByType(state.rooms, 'robot');
      for (const item of robots) {
        await updateDeviceForUser(user, {
          deviceId: item.device.id,
          type: 'robot',
          power: action.power === true,
          cleanMode: 'auto',
          activityArea: item.device.activityArea || item.room.name,
          battery: typeof item.device.battery === 'number' ? item.device.battery : 86,
          cleaningProgress: action.power === true ? undefined : 0
        }, 'generic');
      }
      resultLines.push(`扫地机器人：${action.power === true ? '开始清扫' : '已停止清扫'}`);
      continue;
    }
  }

  resultLines.push('状态已同步到数字孪生平台');
  await addLog(user.id, user.username, 'AI_HOUSEKEEPER_EXECUTE', 'AI housekeeper', normalizedPlan.summary || 'ai plan executed');
  return {
    success: true,
    executionTitle: '已完成全屋协同调度',
    executionLines: resultLines
  };
}

async function route(req, res) {
  let pathname = req.url || '/';
  let parsedUrl = null;
  try {
    parsedUrl = new URL(req.url || '/', 'http://127.0.0.1');
    pathname = parsedUrl.pathname;
  } catch (error) {
    pathname = req.url || '/';
  }

  if (req.method === 'OPTIONS') {
    sendJson(res, 200, { success: true });
    return;
  }

  if (req.method === 'GET' && pathname === '/') {
    sendHtml(res, 'index.html');
    return;
  }

  if (req.method === 'GET' && pathname === '/bedroom') {
    sendHtml(res, 'bedroom.html');
    return;
  }

  if ((req.method === 'GET' || req.method === 'HEAD') && (pathname.startsWith('/assets/') || pathname.startsWith('/vendor/'))) {
    sendPublicAsset(res, pathname, pathname.startsWith('/assets/') ? '/assets/' : '/vendor/', req.method, req.headers.range);
    return;
  }

  if ((req.method === 'GET' || req.method === 'HEAD') && pathname.startsWith('/music/')) {
    const relativePath = decodeURIComponent(pathname.replace(/^\/music\//, ''));
    const safePath = path.normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
    const filePath = path.resolve(MUSIC_ROOT, safePath);
    const musicRootResolved = path.resolve(MUSIC_ROOT);
    if (!filePath.startsWith(musicRootResolved) || !fs.existsSync(filePath)) {
      sendJson(res, 404, { success: false, message: 'music not found' });
      return;
    }
    sendFile(res, filePath, req.method, req.headers.range);
    return;
  }

  if ((req.method === 'GET' || req.method === 'HEAD') && pathname.startsWith('/uploads/')) {
    const relativePath = pathname.replace(/^\/uploads\//, '');
    const safePath = path.normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
    const filePath = path.resolve(UPLOADS_ROOT, safePath);
    const uploadsRootResolved = path.resolve(UPLOADS_ROOT);
    if (!filePath.startsWith(uploadsRootResolved) || !fs.existsSync(filePath)) {
      sendJson(res, 404, { success: false, message: 'file not found' });
      return;
    }
    sendFile(res, filePath, req.method, req.headers.range);
    return;
  }

  if (req.method === 'POST' && req.url === '/api/register') {
    const data = await readJson(req);
    if (!data.username || !data.password) {
      sendJson(res, 400, { success: false, message: 'username and password are required' });
      return;
    }
    const result = await createUser(data.username.trim(), data.password);
    if (result.error) {
      sendJson(res, 409, { success: false, message: result.error });
      return;
    }
    await addLog(result.id, result.username, 'REGISTER', 'smart home', 'user ' + result.username + ' registered');
    sendJson(res, 200, {
      success: true,
      storage: dbMode,
      message: '注册成功',
      username: result.username,
      role: result.role
    });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/login') {
    const data = await readJson(req);
    const user = await validateUser(data.username, data.password);
    if (!user) {
      sendJson(res, 401, { success: false, message: 'invalid username or password' });
      return;
    }
    await addLog(user.id, user.username, 'LOGIN', 'smart home', '用户 ' + user.username + ' 已登录');
    sendJson(res, 200, {
      success: true,
      storage: dbMode,
      message: '登录成功',
      username: user.username,
      role: user.role
    });
    return;
  }

  if (req.method === 'GET' && req.url.startsWith('/api/status')) {
    const username = userFromQuery(req.url);
    const data = await buildStateForUser(username);
    if (!data) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, data });
    return;
  }

  if (req.method === 'GET' && pathname === '/api/music/library') {
    sendJson(res, 200, { success: true, storage: dbMode, tracks: getMusicLibrary() });
    return;
  }

  if (req.method === 'GET' && req.url.startsWith('/api/logs')) {
    const username = userFromQuery(req.url);
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const logs = await getLogsForUser(user.id, username);
    sendJson(res, 200, { success: true, storage: dbMode, logs });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/utility/recharge') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await rechargeUtilityAccount(user, `${data.utilityType || ''}`.trim(), data.amount);
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    await addLog(user.id, user.username, 'UTILITY_RECHARGE', 'utility recharge', (data.utilityType || '') + ' recharge ' + result.amount);
    sendJson(res, 200, { success: true, storage: dbMode, utilityAccount: result.account });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/family-members') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await addFamilyMember(user, data.name, data.phone);
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    await addLog(user.id, user.username, 'FAMILY_ADD', 'family', 'added member ' + result.member.name);
    sendJson(res, 200, { success: true, storage: dbMode, member: result.member });
    return;
  }

  if (req.method === 'GET' && pathname === '/api/door/camera/latest') {
    const username = parsedUrl ? (parsedUrl.searchParams.get('username') || USERNAME) : USERNAME;
    const requestedDeviceId = parsedUrl ? `${parsedUrl.searchParams.get('deviceId') || ''}`.trim() : '';
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }

    const userState = await buildStateForUser(username);
    if (!userState) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }

    let target = requestedDeviceId ? findDeviceInRooms(userState.rooms, requestedDeviceId) : null;
    if (!target) {
      for (const room of userState.rooms) {
        const firstDoor = room.devices.find((item) => item.type === 'door');
        if (firstDoor) {
          target = { room, device: firstDoor };
          break;
        }
      }
    }

    if (!target || target.device.type !== 'door') {
      sendJson(res, 404, { success: false, message: 'door device not found' });
      return;
    }

    const camera = (await getLatestDoorCameraRecord(user.id, target.device.id)) || fallbackCameraRecord(target.device);
    sendJson(res, 200, { success: true, storage: dbMode, camera });
    return;
  }

  if (req.method === 'POST' && pathname === '/api/door/camera/upload') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await uploadDoorCameraForUser(user, `${data.deviceId || ''}`.trim(), data);
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, camera: result.camera });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/rooms') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    if (!data.name || `${data.name}`.trim().length === 0) {
      sendJson(res, 400, { success: false, message: '房间名称不能为空' });
      return;
    }
    const room = await ensureRoomForUser(user, `${data.name}`.trim());
    sendJson(res, 200, { success: true, storage: dbMode, room });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/devices') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    if (!data.name || !data.roomName) {
      sendJson(res, 400, { success: false, message: 'device name and room name are required' });
      return;
    }
    const result = await createDeviceForUser(
      user,
      `${data.roomName}`.trim(),
      `${data.name}`.trim(),
      `${data.type || ''}`.trim()
    );
    sendJson(res, 200, { success: true, storage: dbMode, roomId: result.roomId, device: result.device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/device/delete') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await deleteDeviceForUser(user, `${data.deviceId || ''}`.trim());
    if (result.error) {
      sendJson(res, 404, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, device: result.device, roomId: result.roomId });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/light') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const device = await updateDeviceForUser(user, data, 'light');
    if (device.error) {
      sendJson(res, 404, { success: false, message: device.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/door/unlock') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await unlockDoorForUser(user, `${data.deviceId || ''}`.trim(), `${data.pin || ''}`.trim());
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, message: '门禁已解锁', device: result.device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/door/lock') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await lockDoorForUser(user, String(data.deviceId || '').trim(), '用户执行一键上锁');
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, message: '门禁已上锁', device: result.device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/door/visitor/mock') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await updateDoorVisitorForUser(user, `${data.deviceId || ''}`.trim(), `${data.visitorType || ''}`.trim());
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, message: '访客状态已更新', device: result.device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/door') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const device = await updateDeviceForUser(user, data, 'door');
    if (device.error) {
      sendJson(res, 404, { success: false, message: device.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/air') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const device = await updateDeviceForUser(user, data, 'air');
    if (device.error) {
      sendJson(res, 404, { success: false, message: device.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/environment') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }

    const environment = {
      roomName: `${data.roomName || ''}`.trim(),
      temperature: typeof data.temperature === 'number' ? clamp(data.temperature, 16, 35) : 26,
      humidity: typeof data.humidity === 'number' ? clamp(data.humidity, 20, 80) : 48
    };
    await saveEnvironmentConfig(user.id, user.username, environment);
    await addLog(user.id, user.username, 'ENVIRONMENT_UPDATE', 'environment', 'environment updated to ' + environment.temperature + 'C / ' + environment.humidity + '%');
    sendJson(res, 200, { success: true, storage: dbMode, environment });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/device') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const type = data.type || '';
    const device = await updateDeviceForUser(user, data, type === 'door' ? 'door' : type === 'air' ? 'air' : 'generic');
    if (device.error) {
      sendJson(res, 404, { success: false, message: device.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, device });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/type-control') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const result = await controlTypeForUser(user, data.type, data.power === true, data.roomName || '');
    if (result.error) {
      sendJson(res, 404, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/scene-config') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const config = normalizeSceneConfig({
      home: data.home,
      away: data.away,
      sleep: data.sleep,
      energy: data.energy,
      customModes: Array.isArray(data.customModes) ? data.customModes : []
    });
    await saveSceneConfig(user.id, user.username, config);
    await addLog(user.id, user.username, 'SCENE_CONFIG', 'scene config', 'scene config updated');
    sendJson(res, 200, { success: true, storage: dbMode, sceneConfig: config });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/scene/apply') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const scene = typeof data.scene === 'string' && data.scene.length > 0 ? data.scene : 'home';
    const result = await applySmartSceneForUser(user, scene);
    if (result.error) {
      sendJson(res, 404, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, scene: scene });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/ai/housekeeper') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    const userInput = `${data.userInput || ''}`.trim();
    if (!userInput) {
      sendJson(res, 400, { success: false, message: 'userInput 不能为空' });
      return;
    }
    const result = await createHousekeeperPlanForUser(user, userInput);
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, plan: result.plan, state: result.state });
    return;
  }

  if (req.method === 'POST' && req.url === '/api/ai/execute') {
    const data = await readJson(req);
    const username = data.username || USERNAME;
    const user = await getUserByUsername(username);
    if (!user) {
      sendJson(res, 404, { success: false, message: 'user not found' });
      return;
    }
    if (!data.plan || !Array.isArray(data.plan.actions)) {
      sendJson(res, 400, { success: false, message: 'plan.actions 不能为空' });
      return;
    }
    const result = await executeHousekeeperPlanForUser(user, data.plan);
    if (result.error) {
      sendJson(res, 400, { success: false, message: result.error });
      return;
    }
    sendJson(res, 200, { success: true, storage: dbMode, ...result });
    return;
  }

  sendJson(res, 404, { success: false, message: 'api not found' });
}

async function start() {
  try {
    await initDatabase();
  } catch (error) {
    dbPool = null;
    dbMode = 'memory';
    console.log('MySQL init failed, fallback to memory mode: ' + error.message);
  }

  const demoUser = await getUserByUsername(USERNAME);
  if (demoUser) {
    await addLog(demoUser.id, demoUser.username, 'SERVER_START', 'backend', 'backend initialized, storage mode: ' + dbMode);
  }

  const server = http.createServer(async (req, res) => {
    try {
      await route(req, res);
    } catch (error) {
      sendJson(res, 500, { success: false, message: '服务异常', detail: error.message });
    }
  });

  server.listen(PORT, () => {
    console.log(`演示账号：${USERNAME} / ${PASSWORD}`);
    console.log(`演示地址：http://127.0.0.1:${PORT}/bedroom?username=${encodeURIComponent(USERNAME)}`);
  });
}

start();


