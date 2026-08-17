import http from '@ohos.net.http';

interface AuthResponse {
  success: boolean;
  message: string;
  username?: string;
  role?: string;
}

interface DeviceInfo {
  id: string;
  type: string;
  name: string;
  power: boolean;
  locked?: boolean;
  lockStatus?: string;
  doorStatus?: string;
  cameraStatus?: string;
  visitorType?: string;
  visitorName?: string;
  riskLevel?: string;
  visitorVerified?: boolean;
  failedAttempts?: number;
  lockUntil?: string | null;
  lastUnlockTime?: string | null;
  brightness?: number;
  temperature?: number;
  mode?: string;
  listening?: boolean;
  lastCommand?: string;
  lastBroadcast?: string;
  musicTrackId?: string;
  musicTitle?: string;
  musicArtist?: string;
  musicUrl?: string;
  musicPlaying?: boolean;
  musicStartedAt?: string;
  cleanMode?: string;
  activityArea?: string;
  battery?: number;
  cleaningProgress?: number;
}

interface DeviceControlPayload {
  username: string;
  deviceId: string;
  type?: string;
  power?: boolean;
  cleanMode?: string;
  activityArea?: string;
  battery?: number;
  cleaningProgress?: number;
}

interface RoomInfo {
  id: string;
  name: string;
  devices: DeviceInfo[];
}

interface DeviceCardInfo {
  roomId: string;
  roomName: string;
  device: DeviceInfo;
}

interface LogInfo {
  id: number;
  time: string;
  action: string;
  target: string;
  detail: string;
}

interface SceneDevicePreset {
  deviceId: string;
  deviceType: string;
  deviceName: string;
  roomName: string;
  enabled: boolean;
  brightness?: number;
  temperature?: number;
  mode?: string;
  locked?: boolean;
}

interface SceneModePreset {
  key: string;
  label: string;
  builtIn?: boolean;
  devices: SceneDevicePreset[];
}

interface SceneConfig {
  home: SceneModePreset;
  away: SceneModePreset;
  sleep: SceneModePreset;
  energy: SceneModePreset;
  customModes?: SceneModePreset[];
}

interface EnvironmentInfo {
  roomName?: string;
  temperature: number;
  humidity: number;
}

interface UtilityAccount {
  electricBalance: number;
  gasBalance: number;
  waterBalance: number;
}

interface FamilyMemberInfo {
  id: number;
  name: string;
  phone: string;
  roleLabel: string;
  createdAt?: string;
}

interface HousekeeperAction {
  key: string;
  deviceType: string;
  title: string;
  detail: string;
  reason: string;
  power?: boolean;
  brightness?: number;
  temperature?: number;
  mode?: string;
  locked?: boolean;
}

interface HousekeeperPlan {
  intent: string;
  intentLabel: string;
  summary: string;
  messageToUser: string;
  needConfirm: boolean;
  actions: HousekeeperAction[];
}

interface StatusData {
  homeName: string;
  mode: string;
  updatedAt: string;
  rooms: RoomInfo[];
  logs: LogInfo[];
  sceneConfig?: SceneConfig;
  environment?: EnvironmentInfo;
  utilityAccount?: UtilityAccount;
  familyMembers?: FamilyMemberInfo[];
}

interface StatusResponse {
  success: boolean;
  storage: string;
  data: StatusData;
}

interface ActionResponse {
  success: boolean;
  message?: string;
}

interface HousekeeperPlanResponse {
  success: boolean;
  message?: string;
  plan?: HousekeeperPlan;
}

interface HousekeeperExecuteResponse {
  success: boolean;
  message?: string;
  executionTitle?: string;
  executionLines?: string[];
}

interface UtilityRechargeResponse {
  success: boolean;
  message?: string;
  utilityAccount?: UtilityAccount;
}

interface DoorCameraInfo {
  id: number;
  deviceId: string;
  videoUrl: string;
  coverUrl: string;
  capturedAt: string;
  durationSec?: number | null;
  cameraStatus?: string;
  notes?: string;
}

interface DoorCameraResponse {
  success: boolean;
  storage: string;
  camera?: DoorCameraInfo;
  message?: string;
}

interface HttpHeader {
  'Content-Type': string;
}

interface HttpRequestOptions {
  method: http.RequestMethod;
  header?: HttpHeader;
  extraData?: string;
  connectTimeout: number;
  readTimeout: number;
}

class TypeOption {
  key: string;
  label: string;
  icon: string;

  constructor(key: string, label: string, icon: string) {
    this.key = key;
    this.label = label;
    this.icon = icon;
  }
}

class BottomTabOption {
  key: string;
  label: string;
  icon: string;

  constructor(key: string, label: string, icon: string) {
    this.key = key;
    this.label = label;
    this.icon = icon;
  }
}

class HousekeeperPresetOption {
  key: string;
  label: string;
  prompt: string;

  constructor(key: string, label: string, prompt: string) {
    this.key = key;
    this.label = label;
    this.prompt = prompt;
  }
}

class BasePayload {
  username: string = '';
}

class TypeControlPayload extends BasePayload {
  type: string = '';
  power: boolean = false;
  roomName?: string;
}

class SceneApplyPayload extends BasePayload {
  scene: string = '';
}

class SceneDevicePresetPayload {
  deviceId: string = '';
  deviceType: string = '';
  deviceName: string = '';
  roomName: string = '';
  enabled: boolean = false;
  brightness?: number;
  temperature?: number;
  mode?: string;
  locked?: boolean;
}

class SceneModePresetPayload {
  key: string = '';
  label: string = '';
  builtIn: boolean = false;
  devices: SceneDevicePresetPayload[] = [];
}

class LegacySceneConfig {
  homeTypes?: string[];
  awayTypes?: string[];
  sleepTypes?: string[];
  energyTypes?: string[];
  home?: SceneModePreset;
  away?: SceneModePreset;
  sleep?: SceneModePreset;
  energy?: SceneModePreset;
  customModes?: SceneModePreset[];
}

class SceneConfigPayload extends BasePayload {
  home: SceneModePresetPayload = new SceneModePresetPayload();
  away: SceneModePresetPayload = new SceneModePresetPayload();
  sleep: SceneModePresetPayload = new SceneModePresetPayload();
  energy: SceneModePresetPayload = new SceneModePresetPayload();
  customModes: SceneModePresetPayload[] = [];
}

class AddDevicePayload extends BasePayload {
  name: string = '';
  roomName: string = '';
  type: string = '';
}

class DeleteDevicePayload extends BasePayload {
  deviceId: string = '';
}

class DoorUnlockPayload extends BasePayload {
  deviceId: string = '';
  pin: string = '';
}

class DoorLockPayload extends BasePayload {
  deviceId: string = '';
}

class AuthPayload {
  username: string = '';
  password: string = '';
}

class HousekeeperPlanPayload extends BasePayload {
  userInput: string = '';
}

class HousekeeperExecutePayload extends BasePayload {
  plan: HousekeeperPlan | null = null;
}

class UtilityRechargePayload extends BasePayload {
  utilityType: string = 'electric';
  amount: number = 0;
}

class FamilyMemberPayload extends BasePayload {
  name: string = '';
  phone: string = '';
}

@Entry
@Component
struct Index {
  private readonly statusRefreshIntervalMs: number = 3000;
  private statusRefreshTimer: number = -1;
  @State isLoggedIn: boolean = false;
  @State isRegisterMode: boolean = false;
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State currentUser: string = '';
  @State apiBaseUrl: string = 'http://127.0.0.1:3027';

  @State homeName: string = '我的家';
  @State currentMode: string = 'home';
  @State storageMode: string = '--';
  @State updatedAt: string = '--';
  @State currentTemperatureText: string = '--';
  @State currentHumidityText: string = '--';
  @State rooms: RoomInfo[] = [];
  @State logs: LogInfo[] = [];
  @State selectedBottomTab: string = 'home';
  @State selectedType: string = 'door';
  @State selectedRoomFilter: string = '全部';
  @State syncMessage: string = '等待同步';

  @State housekeeperInput: string = '';
  @State housekeeperSelectedPreset: string = '';
  @State housekeeperPlan: HousekeeperPlan | null = null;
  @State housekeeperStatus: string = '等待生成调度方案';
  @State housekeeperExecutionTitle: string = '';
  @State housekeeperExecutionLines: string[] = [];
  @State housekeeperExecuting: boolean = false;
  @State selectedSceneMode: string = 'away';
  @State showAddMenuDialog: boolean = false;
  @State showAddDeviceDialog: boolean = false;
  @State showSceneDialog: boolean = false;
  @State showAddSceneModeDialog: boolean = false;
  @State showDoorUnlockDialog: boolean = false;
  @State showUtilityDialog: boolean = false;
  @State showFamilyDialog: boolean = false;

  @State modalDeviceName: string = '';
  @State modalRoomName: string = '';
  @State modalDeviceType: string = 'light';
  @State utilityAccount: UtilityAccount = { electricBalance: 0, gasBalance: 0, waterBalance: 0 };
  @State familyMembers: FamilyMemberInfo[] = [];
  @State selectedUtilityType: string = 'electric';
  @State utilityRechargeAmount: string = '';
  @State familyMemberName: string = '';
  @State familyMemberPhone: string = '';
  @State sceneModeDraftName: string = '';
  @State sceneConfig: SceneConfig = this.defaultSceneConfig();
  @State lightBrightness: number = 72;
  @State airTemperature: number = 26;
  @State currentAirModeText: string = '制冷';
  @State doorUnlockDeviceId: string = '';
  @State doorUnlockPin: string = '';
  @State doorCameraCheckedDeviceId: string = '';
  @State doorCameraInfo: DoorCameraInfo | null = null;
  @State voiceListening: boolean = false;

  private doorVideoController: VideoController = new VideoController();
  private readonly airModes: string[] = ['制冷', '制热', '除湿', '送风', '睡眠'];
  private readonly curtainModes: string[] = ['自动', '手动', '睡眠', '节能'];

  private typeOptions(): TypeOption[] {
    return [
      new TypeOption('light', '灯光', '灯'),
      new TypeOption('curtain', '窗帘', '帘'),
      new TypeOption('air', '空调', '空'),
      new TypeOption('door', '门禁', '门'),
      new TypeOption('speaker', '音箱', '音'),
      new TypeOption('robot', '扫地', '扫'),
      new TypeOption('tv', '电视', '视'),
      new TypeOption('other', '其他', '设')
    ];
  }

  private visibleTypeKeys(): string[] {
    return ['door', 'light', 'air', 'curtain', 'speaker', 'robot'];
  }

  private visibleTypeOptions(): TypeOption[] {
    let ordered: TypeOption[] = [];
    let keys = this.visibleTypeKeys();
    let options = this.typeOptions();
    for (let i = 0; i < keys.length; i += 1) {
      for (let j = 0; j < options.length; j += 1) {
        if (options[j].key === keys[i]) {
          ordered.push(options[j]);
          break;
        }
      }
    }
    return ordered;
  }

  private bottomTabOptions(): BottomTabOption[] {
    return [
      new BottomTabOption('home', '鸿居', '居'),
      new BottomTabOption('scene', '场景', '景'),
      new BottomTabOption('butler', '管家', '管'),
      new BottomTabOption('profile', '我的', '我')
    ];
  }

  private housekeeperPresetOptions(): HousekeeperPresetOption[] {
    return [
      new HousekeeperPresetOption('elder_comfort', '老人舒适', '家里有老人，请把全屋设备调整到舒适模式'),
      new HousekeeperPresetOption('sleep_mode', '睡眠模式', '准备休息了，请把家里的设备调整到适合睡眠的状态'),
      new HousekeeperPresetOption('away_safe', '离家安全', '我要出门了，请把全屋设备切换到离家安全模式'),
      new HousekeeperPresetOption('energy_save', '节能模式', '今天想省电，请帮我把家里调整到节能模式')
    ];
  }

  private parseAuthResponse(raw: string): AuthResponse {
    return JSON.parse(raw) as AuthResponse;
  }

  private parseStatusResponse(raw: string): StatusResponse {
    return JSON.parse(raw) as StatusResponse;
  }

  private parseActionResponse(raw: string): ActionResponse {
    return JSON.parse(raw) as ActionResponse;
  }

  private parseHousekeeperPlanResponse(raw: string): HousekeeperPlanResponse {
    let response = JSON.parse(raw) as HousekeeperPlanResponse;
    if (response.plan) {
      response.plan = this.normalizeHousekeeperPlan(response.plan);
    }
    return response;
  }

  private parseHousekeeperExecuteResponse(raw: string): HousekeeperExecuteResponse {
    return JSON.parse(raw) as HousekeeperExecuteResponse;
  }

  private parseDoorCameraResponse(raw: string): DoorCameraResponse {
    return JSON.parse(raw) as DoorCameraResponse;
  }

  private parseUtilityRechargeResponse(raw: string): UtilityRechargeResponse {
    return JSON.parse(raw) as UtilityRechargeResponse;
  }

  private showDialog(message: string): void {
    AlertDialog.show({
      message: message,
      alignment: DialogAlignment.Center,
      autoCancel: true
    });
  }

  private confirmDeleteDevice(card: DeviceCardInfo): void {
    AlertDialog.show({
      title: '\u5220\u9664\u8bbe\u5907',
      message: '\u786e\u8ba4\u5220\u9664 \"' + card.device.name + '\" \u5417\uff1f\u5220\u9664\u540e\u5c06\u4ece\u5f53\u524d\u623f\u95f4\u79fb\u9664\u3002',
      alignment: DialogAlignment.Center,
      autoCancel: true,
      primaryButton: {
        value: '\u53d6\u6d88',
        action: () => {
        }
      },
      secondaryButton: {
        value: '\u5220\u9664',
        action: () => {
          this.deleteDevice(card);
        }
      }
    });
  }

  private deleteDevice(card: DeviceCardInfo): void {
    this.requestPost('/api/device/delete', this.createDeleteDevicePayload(card.device.id), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('\u5220\u9664\u8bbe\u5907\u5931\u8d25');
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.showDialog(response.message ? response.message : '\u5220\u9664\u8bbe\u5907\u5931\u8d25');
        return;
      }
      this.showDialog('\u8bbe\u5907\u5df2\u5220\u9664');
      this.loadStatus();
    });
  }

  private markLocalDemoMode(): void {
    this.syncMessage = '本地演示模式';
  }

  private candidateApiBaseUrls(): string[] {
    return [
      this.apiBaseUrl,
      'http://127.0.0.1:3027',
      'http://10.0.2.2:3027',
      'http://192.168.137.1:3027'
    ];
  }

  private requestPostByIndex(url: string, body: string, baseUrls: string[], index: number,
    callback: (success: boolean, result: string) => void): void {
    if (index >= baseUrls.length) {
      callback(false, '');
      return;
    }
    let request = http.createHttp();
    let header: HttpHeader = { 'Content-Type': 'application/json; charset=utf-8' };
    let options: HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: header,
      extraData: body,
      connectTimeout: 5000,
      readTimeout: 5000
    };
    let currentBaseUrl = baseUrls[index];
    request.request(currentBaseUrl + url, options, (error, response) => {
      if (error) {
        request.destroy();
        this.requestPostByIndex(url, body, baseUrls, index + 1, callback);
        return;
      }
      this.apiBaseUrl = currentBaseUrl;
      callback(true, response.result.toString());
      request.destroy();
    });
  }

  private requestPost(url: string, body: string, callback: (success: boolean, result: string) => void): void {
    this.requestPostByIndex(url, body, this.candidateApiBaseUrls(), 0, callback);
  }

  private requestGetByIndex(url: string, baseUrls: string[], index: number,
    callback: (success: boolean, result: string) => void): void {
    if (index >= baseUrls.length) {
      callback(false, '');
      return;
    }
    let request = http.createHttp();
    let options: HttpRequestOptions = {
      method: http.RequestMethod.GET,
      connectTimeout: 5000,
      readTimeout: 5000
    };
    let currentBaseUrl = baseUrls[index];
    request.request(currentBaseUrl + url, options, (error, response) => {
      if (error) {
        request.destroy();
        this.requestGetByIndex(url, baseUrls, index + 1, callback);
        return;
      }
      this.apiBaseUrl = currentBaseUrl;
      callback(true, response.result.toString());
      request.destroy();
    });
  }

  private requestGet(url: string, callback: (success: boolean, result: string) => void): void {
    this.requestGetByIndex(url, this.candidateApiBaseUrls(), 0, callback);
  }

  private usernameQuery(): string {
    if (this.currentUser.length === 0) {
      return '';
    }
    return '?username=' + this.currentUser;
  }

  private authJson(payload?: BasePayload): string {
    if (payload) {
      payload.username = this.currentUser;
      return JSON.stringify(payload);
    }
    let basePayload = new BasePayload();
    basePayload.username = this.currentUser;
    return JSON.stringify(basePayload);
  }

  private createTypeControlPayload(power: boolean, roomName?: string): string {
    let payload = new TypeControlPayload();
    payload.type = this.selectedType;
    payload.power = power;
    if (roomName) {
      payload.roomName = roomName;
    }
    return this.authJson(payload);
  }

  private createSceneApplyPayload(scene: string): string {
    let payload = new SceneApplyPayload();
    payload.scene = scene;
    return this.authJson(payload);
  }

  private createSceneConfigPayload(): string {
    let payload = new SceneConfigPayload();
    payload.home = this.createSceneModePayload(this.sceneConfig.home);
    payload.away = this.createSceneModePayload(this.sceneConfig.away);
    payload.sleep = this.createSceneModePayload(this.sceneConfig.sleep);
    payload.energy = this.createSceneModePayload(this.sceneConfig.energy);
    let customModes = this.sceneConfig.customModes ? this.sceneConfig.customModes : [];
    for (let i = 0; i < customModes.length; i += 1) {
      payload.customModes.push(this.createSceneModePayload(customModes[i]));
    }
    return this.authJson(payload);
  }

  private createSceneDevicePayload(preset: SceneDevicePreset): SceneDevicePresetPayload {
    let payload = new SceneDevicePresetPayload();
    payload.deviceId = preset.deviceId;
    payload.deviceType = preset.deviceType;
    payload.deviceName = preset.deviceName;
    payload.roomName = preset.roomName;
    payload.enabled = preset.enabled;
    payload.brightness = preset.brightness;
    payload.temperature = preset.temperature;
    payload.mode = preset.mode;
    payload.locked = preset.locked;
    return payload;
  }

  private createSceneModePayload(preset: SceneModePreset): SceneModePresetPayload {
    let payload = new SceneModePresetPayload();
    payload.key = preset.key;
    payload.label = preset.label;
    payload.builtIn = preset.builtIn === true;
    for (let i = 0; i < preset.devices.length; i += 1) {
      payload.devices.push(this.createSceneDevicePayload(preset.devices[i]));
    }
    return payload;
  }

  private createAddDevicePayload(): string {
    let payload = new AddDevicePayload();
    payload.name = this.modalDeviceName.trim();
    payload.roomName = this.modalRoomName.trim();
    payload.type = this.modalDeviceType;
    return this.authJson(payload);
  }

  private createDeleteDevicePayload(deviceId: string): string {
    let payload = new DeleteDevicePayload();
    payload.deviceId = deviceId;
    return this.authJson(payload);
  }

  private createDoorUnlockPayload(deviceId: string, pin: string): string {
    let payload = new DoorUnlockPayload();
    payload.deviceId = deviceId;
    payload.pin = pin;
    return this.authJson(payload);
  }

  private createDoorLockPayload(deviceId: string): string {
    let payload = new DoorLockPayload();
    payload.deviceId = deviceId;
    return this.authJson(payload);
  }

  private createAuthPayload(): string {
    let payload = new AuthPayload();
    payload.username = this.username.trim();
    payload.password = this.password;
    return JSON.stringify(payload);
  }

  private createHousekeeperPlanPayload(): string {
    let payload = new HousekeeperPlanPayload();
    payload.userInput = this.housekeeperInput.trim();
    return this.authJson(payload);
  }

  private createHousekeeperExecutePayload(): string {
    let payload = new HousekeeperExecutePayload();
    payload.plan = this.housekeeperPlan;
    return this.authJson(payload);
  }

  private createUtilityRechargePayload(): string {
    let payload = new UtilityRechargePayload();
    payload.utilityType = this.selectedUtilityType;
    payload.amount = Number.parseFloat(this.utilityRechargeAmount);
    return this.authJson(payload);
  }

  private createFamilyMemberPayload(): string {
    let payload = new FamilyMemberPayload();
    payload.name = this.familyMemberName.trim();
    payload.phone = this.familyMemberPhone.trim();
    return this.authJson(payload);
  }

  private normalizeType(type: string): string {
    if (type === 'light' || type === 'curtain' || type === 'air' || type === 'door' || type === 'tv' ||
      type === 'speaker' || type === 'robot') {
      return type;
    }
    if (type === 'smartCurtain' || type === 'curtains') {
      return 'curtain';
    }
    if (type === 'smartSpeaker') {
      return 'speaker';
    }
    if (type === 'vacuum' || type === 'cleanRobot' || type === 'sweeper') {
      return 'robot';
    }
    return 'other';
  }

  private normalizeDisplayText(text: string): string {
    if (text.length === 0) {
      return '';
    }
    let result = text;
    let replacements: Array<[string, string]> = [
      ['瀹㈠巺', '客厅'],
      ['鍗у', '卧室'],
      ['鍘ㄦ埧', '厨房'],
      ['鍗敓闂', '卫生间'],
      ['鐏厜', '灯光'],
      ['绌鸿皟', '空调'],
      ['鐢佃', '电视'],
      ['鍏ユ埛闂ㄧ', '入户门禁'],
      ['鐨勫', '的家'],
      ['鍏ㄩ儴', '全部'],
      ['绐楀笜', '窗帘'],
      ['鍏朵粬', '其他'],
      ['鍒跺喎', '制冷'],
      ['鍒剁儹', '制热'],
      ['闄ゆ箍', '除湿'],
      ['閫侀', '送风'],
      ['鐫＄湢', '睡眠'],
      ['鑷姩', '自动'],
      ['鎵嬪姩', '手动'],
      ['鑺傝兘', '节能'],
      ['宸蹭笂閿', '已上锁'],
      ['宸茶В閿', '已解锁'],
      ['闂ㄥ凡鍏抽棴', '门已关闭'],
      ['闂ㄥ凡鎵撳紑', '门已打开'],
      ['绛夊緟鍚屾', '等待同步'],
      ['瀹跺涵鎴愬憳', '家庭成员'],
      ['瀹朵汉', '家人'],
      ['蹇€掑憳', '快递员'],
      ['闄岀敓璁垮', '陌生访客'],
      ['鏃犱汉', '无人'],
      ['鍥炲妯″紡', '回家模式'],
      ['绂诲妯″紡', '离家模式'],
      ['鐫＄湢妯″紡', '睡眠模式'],
      ['鑺傝兘妯″紡', '节能模式'],
      ['宸叉坊鍔犳柊鎴块棿', '已添加新房间'],
      ['访客状态已更新', '访客状态已更新'],
      ['宸叉煡鐪嬬尗鐪兼憚鍍忓ご璁板綍', '已查看猫眼摄像头记录'],
      ['闂ㄤ綋宸叉墦寮€', '门体已打开'],
      ['鍏ユ埛闂ㄥ凡鎵嬪姩涓婇攣', '入户门已手动上锁']
    ];
    for (let i = 0; i < replacements.length; i += 1) {
      result = result.replaceAll(replacements[i][0], replacements[i][1]);
    }

    if (result === 'device on') {
      return '设备已开启';
    }
    if (result === 'device off') {
      return '设备已关闭';
    }
    if (result === 'door locked') {
      return '门禁已上锁';
    }
    if (result === 'door unlocked') {
      return '门禁已解锁';
    }
    if (result === 'door unlock requested') {
      return '已发起远程解锁';
    }
    if (result === 'door auto locked') {
      return '门禁已自动回锁';
    }
    if (result === 'user requested lock') {
      return '用户执行一键上锁';
    }
    if (result === 'high risk visitor detected') {
      return '检测到高风险访客';
    }
    if (result === 'pin verification failed') {
      return 'PIN 验证失败';
    }
    if (result.indexOf('air on ') === 0 || result.indexOf('air off ') === 0) {
      let isOn = result.indexOf('air on ') === 0;
      let suffix = result.substring(7);
      return '空调' + (isOn ? '开启 ' : '关闭 ') + this.normalizeDisplayText(suffix).replace('C', '℃');
    }
    if (result.indexOf('light brightness ') === 0) {
      return '灯光亮度 ' + result.substring(17);
    }
    return result;
  }

  private defaultHousekeeperReason(intent: string, actionKey: string): string {
    if (intent === 'sleep_mode') {
      if (actionKey === 'light') {
        return '减少眩光，帮助休息';
      }
      if (actionKey === 'curtain') {
        return '营造更安静的睡眠光环境';
      }
      if (actionKey === 'air') {
        return '维持更安静舒适的睡眠环境';
      }
      if (actionKey === 'door') {
        return '保障夜间安全';
      }
    }
    if (intent === 'away_safe') {
      if (actionKey === 'light') {
        return '离家后降低能耗';
      }
      if (actionKey === 'curtain') {
        return '离家后保持遮阳与室内私密性';
      }
      if (actionKey === 'air') {
        return '离家场景优先节能';
      }
      if (actionKey === 'door') {
        return '外出时保持安防闭环';
      }
    }
    if (intent === 'energy_save') {
      if (actionKey === 'light') {
        return '在舒适和节能之间做平衡';
      }
      if (actionKey === 'curtain') {
        return '减少空调负载，提升节能效果';
      }
      if (actionKey === 'air') {
        return '避免过度制冷造成额外耗电';
      }
      if (actionKey === 'door') {
        return '安防不参与节能削减';
      }
    }
    if (intent === 'elder_comfort') {
      if (actionKey === 'light') {
        return '老人活动时需要更均匀柔和的光线';
      }
      if (actionKey === 'curtain') {
        return '保留柔和采光，照顾老人休息舒适度';
      }
      if (actionKey === 'air') {
        return '将室内温湿度调整到更舒适的休息状态';
      }
      if (actionKey === 'door') {
        return '老人独处时优先保证门禁安全';
      }
    }
    if (intent === 'music_clean') {
      if (actionKey === 'speaker') {
        return '先启动音乐播放，增强居家体验';
      }
      if (actionKey === 'robot') {
        return '同步开始地面清扫，完成家务联动';
      }
    }
    return '';
  }

  private normalizeHousekeeperReason(intent: string, action: HousekeeperAction): string {
    let normalized = this.normalizeDisplayText(action.reason ? action.reason : '').trim();
    if (normalized === 'reduce glare for rest') {
      return '减少眩光，帮助休息';
    }
    if (normalized === 'turn off all lights while away') {
      return '离家后降低能耗';
    }
    if (normalized === 'close curtains for privacy while away') {
      return '离家后保持遮阳与室内私密性';
    }
    if (normalized === 'keep only essential lighting') {
      return '在舒适和节能之间做平衡';
    }
    if (normalized === 'reduce solar heat through partial curtain closure') {
      return '减少空调负载，提升节能效果';
    }
    if (normalized === 'security remains enabled in energy mode') {
      return '安防不参与节能削减';
    }
    if (normalized.length === 0) {
      return this.defaultHousekeeperReason(intent, action.key);
    }
    let defaultReason = this.defaultHousekeeperReason(intent, action.key);
    if (normalized.indexOf('�') >= 0 || normalized.indexOf('?') >= 0) {
      return defaultReason.length > 0 ? defaultReason : normalized;
    }
    if (normalized.indexOf('瀹') >= 0 || normalized.indexOf('绐') >= 0 || normalized.indexOf('闂') >= 0 ||
      normalized.indexOf('鏈') >= 0 || normalized.indexOf('鍏') >= 0 || normalized.indexOf('鎻') >= 0 ||
      normalized.indexOf('涓') >= 0 || normalized.indexOf('褰') >= 0) {
      return defaultReason.length > 0 ? defaultReason : normalized;
    }
    return normalized;
  }

  private normalizeHousekeeperPlan(plan: HousekeeperPlan): HousekeeperPlan {
    let normalizedActions: HousekeeperAction[] = [];
    for (let i = 0; i < plan.actions.length; i += 1) {
      let action = plan.actions[i];
      normalizedActions.push({
        key: action.key,
        deviceType: action.deviceType,
        title: this.normalizeDisplayText(action.title),
        detail: this.normalizeDisplayText(action.detail),
        reason: this.normalizeHousekeeperReason(plan.intent, action),
        power: action.power,
        brightness: action.brightness,
        temperature: action.temperature,
        mode: action.mode ? this.normalizeDisplayText(action.mode) : undefined,
        locked: action.locked
      });
    }
    return {
      intent: plan.intent,
      intentLabel: this.normalizeDisplayText(plan.intentLabel),
      summary: this.normalizeDisplayText(plan.summary),
      messageToUser: this.normalizeDisplayText(plan.messageToUser),
      needConfirm: plan.needConfirm,
      actions: normalizedActions
    };
  }

  private typeLabel(type: string): string {
    let options = this.typeOptions();
    for (let i = 0; i < options.length; i += 1) {
      if (options[i].key === type) {
        return options[i].label;
      }
    }
    if (type === 'curtain') {
      return '窗帘';
    }
    if (type === 'speaker') {
      return '音箱';
    }
    if (type === 'robot') {
      return '扫地';
    }
    return '其他';
  }

  private typeIcon(type: string): string {
    let options = this.typeOptions();
    for (let i = 0; i < options.length; i += 1) {
      if (options[i].key === type) {
        return options[i].icon;
      }
    }
    if (type === 'curtain') {
      return '帘';
    }
    if (type === 'speaker') {
      return '音';
    }
    if (type === 'robot') {
      return '扫';
    }
    return '设';
  }

  private normalizedRoomKey(roomName: string): string {
    let normalized = roomName.trim().toLowerCase();
    if (normalized.length === 0) {
      return 'room';
    }
    if (normalized === 'zhuwo' || normalized.indexOf('\u4e3b\u5367') >= 0) {
      return 'zhuwo';
    }
    if (normalized === 'ciwo' || normalized.indexOf('\u6b21\u5367') >= 0) {
      return 'ciwo';
    }
    if (normalized === 'woshi' || normalized.indexOf('\u5367') >= 0) {
      return 'woshi';
    }
    if (normalized === 'keting' || normalized.indexOf('\u5ba2\u5385') >= 0) {
      return 'keting';
    }
    if (normalized === 'canting' || normalized.indexOf('\u9910') >= 0) {
      return 'canting';
    }
    if (normalized === 'chufang' || normalized.indexOf('\u53a8') >= 0) {
      return 'chufang';
    }
    if (normalized === 'weishengjian' || normalized.indexOf('\u536b') >= 0 || normalized.indexOf('\u6d74') >= 0) {
      return 'weishengjian';
    }
    if (normalized === 'shufang' || normalized.indexOf('\u4e66') >= 0) {
      return 'shufang';
    }
    return normalized;
  }

  private displayRoomName(roomName: string): string {
    let key = this.normalizedRoomKey(roomName);
    if (key === 'zhuwo') {
      return '\u4e3b\u5367';
    }
    if (key === 'ciwo') {
      return '\u6b21\u5367';
    }
    if (key === 'woshi') {
      return '\u5367\u5ba4';
    }
    if (key === 'keting') {
      return '\u5ba2\u5385';
    }
    if (key === 'canting') {
      return '\u9910\u5385';
    }
    if (key === 'chufang') {
      return '\u53a8\u623f';
    }
    if (key === 'weishengjian') {
      return '\u536b\u751f\u95f4';
    }
    if (key === 'shufang') {
      return '\u4e66\u623f';
    }
    return roomName;
  }

  private roomIcon(roomName: string): string {
    let roomKey = this.normalizedRoomKey(roomName);
    if (roomKey === 'keting') {
      return '客';
    }
    if (roomKey === 'zhuwo' || roomKey === 'ciwo' || roomKey === 'woshi') {
      return '卧';
    }
    if (roomKey === 'canting') {
      return '餐';
    }
    if (roomKey === 'weishengjian') {
      return '卫';
    }
    if (roomKey === 'chufang') {
      return '厨';
    }
    if (roomKey === 'shufang') {
      return '书';
    }
    if (roomName.length === 0) {
      return '房';
    }
    return this.displayRoomName(roomName).substring(0, 1);
  }

  private availableTypes(): string[] {
    let list: string[] = [];
    let all = this.typeOptions();
    for (let i = 0; i < all.length; i += 1) {
      list.push(all[i].key);
    }
    return list;
  }

  private deviceCardsForSelectedType(): DeviceCardInfo[] {
    let result: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (this.normalizeType(device.type) === this.selectedType) {
          result.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return result;
  }

  private filteredDeviceCardsForSelectedType(): DeviceCardInfo[] {
    let cards = this.deviceCardsForSelectedType();
    if (this.selectedRoomFilter === '全部') {
      return cards;
    }
    return cards.filter((card: DeviceCardInfo) => card.roomName === this.selectedRoomFilter);
  }

  private roomNamesForSelectedType(): string[] {
    let names: string[] = ['全部'];
    let cards = this.deviceCardsForSelectedType();
    for (let i = 0; i < cards.length; i += 1) {
      if (names.indexOf(cards[i].roomName) < 0) {
        names.push(cards[i].roomName);
      }
    }
    return names;
  }

  private roomFilterNamesForSelectedType(): string[] {
    if (this.selectedType !== 'air') {
      return this.roomNamesForSelectedType();
    }
    let names: string[] = [];
    let cards = this.deviceCardsForSelectedType();
    for (let i = 0; i < cards.length; i += 1) {
      if (names.indexOf(cards[i].roomName) < 0) {
        names.push(cards[i].roomName);
      }
    }
    return names;
  }

  private defaultRoomFilterForType(type: string): string {
    if (type !== 'air') {
      return '全部';
    }
    let cards = this.deviceCardsForSelectedType();
    for (let i = 0; i < cards.length; i += 1) {
      return cards[i].roomName;
    }
    return '全部';
  }

  private deviceRenderKey(card: DeviceCardInfo): string {
    let powerFlag = card.device.power ? '1' : '0';
    let lockFlag = card.device.locked === false ? 'unlock' : 'lock';
    let brightnessValue = card.device.brightness !== undefined ? card.device.brightness!.toString() : 'na';
    let modeValue = card.device.mode && card.device.mode.length > 0 ? card.device.mode : 'na';
    let extensionFlag = (card.device.cleanMode ? card.device.cleanMode : 'mode') + '_' +
      (card.device.activityArea ? card.device.activityArea : 'area') + '_' +
      (card.device.cleaningProgress !== undefined ? card.device.cleaningProgress.toString() : 'na') + '_' +
      (card.device.lastBroadcast ? card.device.lastBroadcast : 'broadcast');
    let doorFlag = (card.device.doorStatus ? card.device.doorStatus : 'closed') + '_' +
      (card.device.visitorType ? card.device.visitorType : 'none') + '_' +
      (card.device.failedAttempts !== undefined ? card.device.failedAttempts.toString() : '0');
    return card.device.id + '_' + powerFlag + '_' + lockFlag + '_' + brightnessValue + '_' + modeValue + '_' + doorFlag + '_' + extensionFlag;
  }

  private deviceActive(device: DeviceInfo): boolean {
    if (this.normalizeType(device.type) === 'door') {
      return device.locked === false;
    }
    return device.power;
  }

  private deviceStatusText(device: DeviceInfo): string {
    if (this.normalizeType(device.type) === 'door') {
      return device.locked === false ? '已开启' : '已上锁';
    }
    if (this.normalizeType(device.type) === 'light') {
      if (device.brightness !== undefined) {
        return `亮度 ${device.brightness}%`;
      }
      return device.power ? '灯光已开启' : '灯光已关闭';
    }
    if (this.normalizeType(device.type) === 'curtain') {
      let open = device.brightness !== undefined ? device.brightness : 0;
      return `开合度 ${open}%${device.mode ? ' / ' + this.normalizeDisplayText(device.mode) : ''}`;
    }
    if (this.normalizeType(device.type) === 'air') {
      return (device.temperature !== undefined ? `${device.temperature}°C` : '空调') +
        (device.mode ? ` / ${this.normalizeDisplayText(device.mode)}` : '');
    }
    if (this.normalizeType(device.type) === 'speaker') {
      return device.listening === false ? '语音监听已关闭' : '监听中 · ' + (device.lastBroadcast || '等待播报');
    }
    if (this.normalizeType(device.type) === 'robot') {
      return (device.power ? '清扫中' : '待命') + ' · ' +
        '自动 · ' +
        (device.activityArea || '全屋') + ' · ' +
        (device.battery !== undefined ? device.battery.toString() : '--') + '%';
    }
    return this.normalizeDisplayText(device.name);
  }

  private allAirCards(): DeviceCardInfo[] {
    return this.allDeviceCardsByType('air');
  }

  private allDeviceCardsByType(type: string): DeviceCardInfo[] {
    let result: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (this.normalizeType(device.type) === type) {
          result.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return result;
  }

  private findDeviceCardByIdAndType(deviceId: string, type: string): DeviceCardInfo | undefined {
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (device.id === deviceId && this.normalizeType(device.type) === type) {
          return {
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          };
        }
      }
    }
    return undefined;
  }

  private currentAirCards(): DeviceCardInfo[] {
    return this.filteredDeviceCardsForSelectedType().filter((card: DeviceCardInfo) => this.normalizeType(card.device.type) === 'air');
  }

  private ensureValidRoomFilter(): void {
    let roomNames = this.roomFilterNamesForSelectedType();
    if (this.selectedType === 'air' && this.selectedRoomFilter === '全部' && roomNames.length > 0) {
      this.selectedRoomFilter = roomNames[0];
      return;
    }
    if (roomNames.indexOf(this.selectedRoomFilter) < 0) {
      this.selectedRoomFilter = this.defaultRoomFilterForType(this.selectedType);
    }
  }

  private selectType(type: string): void {
    this.selectedType = type;
    this.selectedRoomFilter = this.defaultRoomFilterForType(type);
  }

  private startStatusRefresh(): void {
    this.stopStatusRefresh();
    if (!this.isLoggedIn) {
      return;
    }
    this.statusRefreshTimer = setInterval(() => {
      if (this.isLoggedIn) {
        this.loadStatus();
      }
    }, this.statusRefreshIntervalMs);
  }

  private stopStatusRefresh(): void {
    if (this.statusRefreshTimer >= 0) {
      clearInterval(this.statusRefreshTimer);
      this.statusRefreshTimer = -1;
    }
  }

  private currentAirDevice(): DeviceInfo | undefined {
    let cards = this.currentAirCards();
    if (cards.length === 0) {
      let allCards = this.allAirCards();
      if (allCards.length === 0) {
        return undefined;
      }
      return allCards[0].device;
    }
    return cards[0].device;
  }

  private currentAirRoomName(): string {
    let cards = this.currentAirCards();
    if (cards.length > 0) {
      return this.normalizeDisplayText(cards[0].roomName);
    }
    if (this.selectedRoomFilter !== '全部') {
      return this.normalizeDisplayText(this.selectedRoomFilter);
    }
    return '全部';
  }

  private normalizeAirModeValue(mode?: string): string {
    let raw = this.normalizeDisplayText(mode ? mode.trim() : '');
    if (raw === 'cool') {
      return '制冷';
    }
    if (raw === 'heat') {
      return '制热';
    }
    if (raw === 'dry') {
      return '除湿';
    }
    if (raw === 'fan' || raw === 'fan_only') {
      return '送风';
    }
    if (raw === 'sleep') {
      return '睡眠';
    }
    if (raw === 'auto') {
      return '制冷';
    }
    if (raw === 'energy') {
      return '除湿';
    }
    return raw.length > 0 ? raw : '制冷';
  }

  private currentAirMode(device?: DeviceInfo): string {
    if (device && device.mode && device.mode.length > 0) {
      this.currentAirModeText = this.normalizeAirModeValue(device.mode);
      return this.currentAirModeText;
    }
    return this.currentAirModeText.length > 0 ? this.currentAirModeText : '制冷';
  }

  private isAirModeActive(activeMode: string, mode: string): boolean {
    return this.normalizeAirModeValue(activeMode) === this.normalizeAirModeValue(mode);
  }

  private currentAirTemperature(device?: DeviceInfo): number {
    if (device && device.temperature !== undefined) {
      this.airTemperature = device.temperature;
      return device.temperature;
    }
    return this.airTemperature;
  }

  private hasAirDevices(): boolean {
    return this.allAirCards().length > 0;
  }

  private hasMultipleAirDevices(): boolean {
    return this.allAirCards().length > 1;
  }

  private totalRoomCount(): number {
    return this.rooms.length;
  }

  private totalDeviceCount(): number {
    let count = 0;
    for (let i = 0; i < this.rooms.length; i += 1) {
      count += this.rooms[i].devices.length;
    }
    return count;
  }

  private onlineSecurityCount(): number {
    let count = 0;
    for (let i = 0; i < this.rooms.length; i += 1) {
      for (let j = 0; j < this.rooms[i].devices.length; j += 1) {
        let device = this.rooms[i].devices[j];
        if (this.normalizeType(device.type) === 'door') {
          count += 1;
        }
      }
    }
    return count;
  }

  private averageTemperatureText(): string {
    let total = 0;
    let count = 0;
    for (let i = 0; i < this.rooms.length; i += 1) {
      for (let j = 0; j < this.rooms[i].devices.length; j += 1) {
        let device = this.rooms[i].devices[j];
        if (this.normalizeType(device.type) === 'air' && device.temperature !== undefined) {
          total += device.temperature;
          count += 1;
        }
      }
    }
    if (count === 0) {
      return '--';
    }
    return (total / count).toFixed(1) + '℃';
  }

  private doorLockText(device: DeviceInfo): string {
    if (device.lockStatus === 'unlocked' || device.locked === false) {
      return '\u5df2\u89e3\u9501';
    }
    return '\u5df2\u4e0a\u9501';
  }

  private doorBodyText(device: DeviceInfo): string {
    if (device.doorStatus === 'opened') {
      return '\u95e8\u5df2\u6253\u5f00';
    }
    return '\u95e8\u5df2\u5173\u95ed';
  }

  private visitorNameText(device: DeviceInfo): string {
    if (device.visitorName && device.visitorName.length > 0) {
      return device.visitorName;
    }
    return '\u5f85\u68c0\u6d4b';
  }

  private visitorRiskText(device: DeviceInfo): string {
    if (device.riskLevel === 'high') {
      return '\u9ad8\u98ce\u9669';
    }
    if (device.riskLevel === 'medium') {
      return '\u4e2d\u98ce\u9669';
    }
    return '\u4f4e\u98ce\u9669';
  }

  private visitorRiskColor(device: DeviceInfo): string {
    if (device.riskLevel === 'high') {
      return '#E96B6B';
    }
    if (device.riskLevel === 'medium') {
      return '#F0A94A';
    }
    return '#33A37A';
  }

  private doorCameraText(device: DeviceInfo): string {
    if (device.cameraStatus === 'alert') {
      return '\u5f02\u5e38\u76d1\u6d4b\u4e2d';
    }
    if (device.cameraStatus === 'idle') {
      return '\u5f53\u524d\u65e0\u4eba';
    }
    return '\u8bbf\u5ba2\u753b\u9762\u5df2\u540c\u6b65';
  }

  private doorSecurityNote(device: DeviceInfo): string {
    if (device.lockUntil && device.lockUntil.length > 0) {
      return '\u5b89\u5168\u63d0\u793a\uff1aPIN \u5df2\u88ab\u4e34\u65f6\u9501\u5b9a';
    }
    if (device.riskLevel === 'high') {
      return '\u5b89\u5168\u63d0\u793a\uff1a\u68c0\u6d4b\u5230\u964c\u751f\u8bbf\u5ba2\uff0c\u8bf7\u8c28\u614e\u89e3\u9501';
    }
    if (device.failedAttempts !== undefined && device.failedAttempts > 0) {
      return '\u5b89\u5168\u63d0\u793a\uff1a\u5df2\u6709 PIN \u9a8c\u8bc1\u5931\u8d25\u8bb0\u5f55';
    }
    return '\u5b89\u5168\u72b6\u6001\u6b63\u5e38';
  }

  private doorLogs(deviceName: string): LogInfo[] {
    return this.logs.filter((item: LogInfo) => {
      return item.target === deviceName || item.action.indexOf('DOOR') >= 0 || item.action.indexOf('VISITOR') >= 0;
    }).slice(0, 4);
  }

  private createDeviceControlPayload(device: DeviceInfo, power: boolean): string {
    let nextBrightness = 72;
    if (device.brightness !== undefined && device.brightness > 0) {
      nextBrightness = device.brightness;
    }
    return JSON.stringify({
      username: this.currentUser,
      deviceId: device.id,
      type: device.type,
      power: power,
      locked: this.normalizeType(device.type) === 'door' ? !power : undefined,
      brightness: this.normalizeType(device.type) === 'light' || this.normalizeType(device.type) === 'curtain'
        ? (power ? nextBrightness : 0)
        : undefined,
      mode: this.normalizeType(device.type) === 'curtain'
        ? (device.mode && device.mode.length > 0 ? device.mode : '自动')
        : undefined
    });
  }

  private createBrightnessPayload(device: DeviceInfo, brightness: number): string {
    return JSON.stringify({
      username: this.currentUser,
      deviceId: device.id,
      type: device.type,
      power: brightness > 0,
      brightness: brightness,
      mode: this.normalizeType(device.type) === 'curtain'
        ? (device.mode && device.mode.length > 0 ? device.mode : '自动')
        : undefined
    });
  }

  private createAirPayload(device: DeviceInfo, power: boolean, temperature: number, mode: string): string {
    return JSON.stringify({
      username: this.currentUser,
      deviceId: device.id,
      power: power,
      temperature: temperature,
      mode: mode
    });
  }

  private createSpeakerBroadcastPayload(device: DeviceInfo, command: string, broadcast: string): string {
    return JSON.stringify({
      username: this.currentUser,
      deviceId: device.id,
      type: 'speaker',
      power: true,
      listening: true,
      lastCommand: command,
      lastBroadcast: broadcast
    });
  }

  private createSpeakerMusicPayload(device: DeviceInfo, playing: boolean): string {
    return JSON.stringify({
      username: this.currentUser,
      deviceId: device.id,
      type: 'speaker',
      power: true,
      listening: true,
      musicPlaying: playing,
      musicTrackId: device.musicTrackId || 'demo-tone',
      lastCommand: playing ? '自动播放音乐' : '暂停音乐',
      lastBroadcast: playing ? '正在播放：' + (device.musicTitle || '智能音箱演示音乐') : '音乐已暂停'
    });
  }

  private createRobotPayload(device: DeviceInfo, power: boolean): string {
    let payload: DeviceControlPayload = {
      username: this.currentUser,
      deviceId: device.id,
      type: device.type,
      power: power,
      cleanMode: 'auto',
      activityArea: device.activityArea || '客厅',
      battery: device.battery !== undefined ? device.battery : 86
    };
    if (!power) {
      payload.cleaningProgress = 0;
    }
    return JSON.stringify(payload);
  }

  private currentLightBrightness(): number {
    let cards = this.deviceCardsForSelectedType();
    for (let i = 0; i < cards.length; i += 1) {
      if (cards[i].device.brightness !== undefined) {
        this.lightBrightness = cards[i].device.brightness!;
        return this.lightBrightness;
      }
    }
    return this.lightBrightness;
  }

  private optimisticBrightnessValue(device: DeviceInfo, power: boolean): number {
    if (power) {
      if (device.brightness !== undefined && device.brightness > 0) {
        return device.brightness;
      }
      if (this.lightBrightness > 0) {
        return this.lightBrightness;
      }
      return 72;
    }
    return 0;
  }

  private updateDeviceStateLocal(deviceId: string, updater: (device: DeviceInfo) => DeviceInfo): void {
    this.rooms = this.rooms.map((room: RoomInfo) => {
      let updatedRoom: RoomInfo = {
        id: room.id,
        name: room.name,
        devices: room.devices.map((device: DeviceInfo) => {
          if (device.id !== deviceId) {
            return device;
          }
          return updater(device);
        })
      };
      return updatedRoom;
    });
  }

  private updateSelectedTypeDevicesLocal(power: boolean, roomName?: string): void {
    let nextBrightness = this.lightBrightness > 0 ? this.lightBrightness : 72;
    this.rooms = this.rooms.map((room: RoomInfo) => {
      let roomMatched = roomName === undefined || roomName.length === 0 || room.name === roomName;
      if (!roomMatched) {
        return room;
      }
      let updatedRoom: RoomInfo = {
        id: room.id,
        name: room.name,
        devices: room.devices.map((device: DeviceInfo) => {
          if (this.normalizeType(device.type) !== this.selectedType) {
            return device;
          }
          if (this.selectedType === 'door') {
            return {
              id: device.id,
              type: device.type,
              name: device.name,
              power: power,
              locked: !power,
              brightness: device.brightness,
              temperature: device.temperature,
              mode: device.mode
            };
          }
          if (this.selectedType === 'light') {
            return {
              id: device.id,
              type: device.type,
              name: device.name,
              power: power,
              locked: device.locked,
              brightness: power
                ? (device.brightness !== undefined && device.brightness > 0 ? device.brightness : nextBrightness)
                : 0,
              temperature: device.temperature,
              mode: device.mode
            };
          }
          if (this.selectedType === 'curtain') {
            return {
              id: device.id,
              type: device.type,
              name: device.name,
              power: power,
              locked: device.locked,
              brightness: power
                ? (device.brightness !== undefined && device.brightness > 0 ? device.brightness : nextBrightness)
                : 0,
              temperature: device.temperature,
              mode: power ? (device.mode && device.mode.length > 0 ? device.mode : '自动') : (device.mode && device.mode.length > 0 ? device.mode : '手动')
            };
          }
          return {
            id: device.id,
            type: device.type,
            name: device.name,
            power: power,
            locked: device.locked,
            brightness: device.brightness,
            temperature: device.temperature,
            mode: device.mode
          };
        })
      };
      return updatedRoom;
    });
    if (this.selectedType === 'light') {
      this.lightBrightness = power ? nextBrightness : 0;
    }
  }

  private updateSelectedLightBrightnessLocal(brightness: number): void {
    this.rooms = this.rooms.map((room: RoomInfo) => {
      let updatedRoom: RoomInfo = {
        id: room.id,
        name: room.name,
        devices: room.devices.map((device: DeviceInfo) => {
          if (this.normalizeType(device.type) !== 'light' && this.normalizeType(device.type) !== 'curtain') {
            return device;
          }
          return {
            id: device.id,
            type: device.type,
            name: device.name,
            power: brightness > 0,
            locked: device.locked,
            brightness: brightness,
            temperature: device.temperature,
            mode: this.normalizeType(device.type) === 'curtain'
              ? (device.mode && device.mode.length > 0 ? device.mode : '自动')
              : device.mode
          };
        })
      };
      return updatedRoom;
    });
    this.lightBrightness = brightness;
  }

  private openDoorUnlockDialog(device: DeviceInfo): void {
    this.doorUnlockDeviceId = device.id;
    this.doorUnlockPin = '';
    this.showDoorUnlockDialog = true;
  }

  private closeDoorUnlockDialog(): void {
    this.showDoorUnlockDialog = false;
    this.doorUnlockDeviceId = '';
    this.doorUnlockPin = '';
    this.doorCameraInfo = null;
  }

  private hasCheckedDoorCamera(device: DeviceInfo): boolean {
    return this.doorCameraCheckedDeviceId === device.id;
  }

  private currentDoorDialogDevice(): DeviceInfo | undefined {
    if (this.doorUnlockDeviceId.length === 0) {
      return undefined;
    }
    return this.findDeviceById(this.doorUnlockDeviceId);
  }

  private viewDoorCamera(device: DeviceInfo): void {
    this.doorUnlockDeviceId = device.id;
    this.requestGet('/api/door/camera/latest?username=' + this.currentUser + '&deviceId=' + device.id,
      (success: boolean, result: string) => {
        if (!success) {
          this.showDialog('\u67e5\u770b\u6444\u50cf\u5934\u5931\u8d25');
          return;
        }
        let response = this.parseDoorCameraResponse(result);
        if (!response.success || response.camera === undefined) {
          this.showDialog(response.message ? response.message : '\u67e5\u770b\u6444\u50cf\u5934\u5931\u8d25');
          return;
        }
        this.doorCameraCheckedDeviceId = device.id;
        this.doorCameraInfo = response.camera;
        this.showDoorUnlockDialog = true;
      });
  }

  private lockDoor(device: DeviceInfo): void {
    this.requestPost('/api/door/lock', this.createDoorLockPayload(device.id), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('\u4e00\u952e\u4e0a\u9501\u5931\u8d25');
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.showDialog(response.message ? response.message : '\u4e00\u952e\u4e0a\u9501\u5931\u8d25');
        return;
      }
      if (this.doorCameraCheckedDeviceId === device.id) {
        this.doorCameraCheckedDeviceId = '';
      }
      this.closeDoorUnlockDialog();
      this.loadStatus();
    });
  }

  private confirmDoorUnlock(): void {
    if (this.doorUnlockDeviceId.length === 0) {
      this.showDialog('\u672a\u9009\u62e9\u95e8\u7981\u8bbe\u5907');
      return;
    }
    if (this.doorUnlockPin.trim().length === 0) {
      this.showDialog('\u8bf7\u8f93\u5165\u5b89\u5168 PIN');
      return;
    }
    this.requestPost('/api/door/unlock', this.createDoorUnlockPayload(this.doorUnlockDeviceId, this.doorUnlockPin.trim()),
      (success: boolean, result: string) => {
        if (!success) {
          this.showDialog('\u8fdc\u7a0b\u89e3\u9501\u5931\u8d25');
          return;
        }
        let response = this.parseActionResponse(result);
        if (!response.success) {
          this.showDialog(response.message ? response.message : '\u8fdc\u7a0b\u89e3\u9501\u5931\u8d25');
          return;
        }
        this.closeDoorUnlockDialog();
        this.loadStatus();
      });
  }

  private unlockDoor(device: DeviceInfo): void {
    if (!this.hasCheckedDoorCamera(device)) {
      this.showDialog('\u8bf7\u5148\u67e5\u770b\u95e8\u53e3\u753b\u9762\uff0c\u518d\u6267\u884c\u8fdc\u7a0b\u89e3\u9501');
      return;
    }
    this.doorUnlockDeviceId = device.id;
    this.doorUnlockPin = '123456';
    this.confirmDoorUnlock();
  }

  private cameraTimeText(value?: string): string {
    if (!value || value.length < 19) {
      return '--';
    }
    return value.substring(0, 19).replace('T', ' ');
  }

  controlDevice(device: DeviceInfo, power: boolean): void {
    if (this.normalizeType(device.type) === 'light' || this.normalizeType(device.type) === 'curtain') {
      let nextBrightness = this.optimisticBrightnessValue(device, power);
      this.updateDeviceStateLocal(device.id, (current: DeviceInfo): DeviceInfo => {
        return {
          id: current.id,
          type: current.type,
          name: current.name,
          power: power,
          locked: current.locked,
          brightness: nextBrightness,
          temperature: current.temperature,
          mode: this.normalizeType(current.type) === 'curtain'
            ? (power ? (current.mode && current.mode.length > 0 ? current.mode : '自动') : (current.mode && current.mode.length > 0 ? current.mode : '手动'))
            : current.mode
        };
      });
      if (this.normalizeType(device.type) === 'light') {
        this.lightBrightness = nextBrightness;
      }
    } else if (this.normalizeType(device.type) === 'door') {
      this.updateDeviceStateLocal(device.id, (current: DeviceInfo): DeviceInfo => {
        return {
          id: current.id,
          type: current.type,
          name: current.name,
          power: power,
          locked: !power,
          brightness: current.brightness,
          temperature: current.temperature,
          mode: current.mode
        };
      });
    } else {
      this.updateDeviceStateLocal(device.id, (current: DeviceInfo): DeviceInfo => {
        return {
          id: current.id,
          type: current.type,
          name: current.name,
          power: power,
          locked: current.locked,
          brightness: current.brightness,
          temperature: current.temperature,
          mode: current.mode
        };
      });
    }
    this.requestPost('/api/device', this.createDeviceControlPayload(device, power), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.markLocalDemoMode();
        return;
      }
      this.loadStatus();
    });
  }

  updateLightBrightness(value: number): void {
    this.lightBrightness = value;
  }

  private currentDeviceBrightness(device: DeviceInfo): number {
    if (device.brightness !== undefined) {
      return device.brightness;
    }
    if (this.normalizeType(device.type) === 'curtain') {
      return 60;
    }
    return 72;
  }

  private findDeviceById(deviceId: string): DeviceInfo | undefined {
    for (let i = 0; i < this.rooms.length; i += 1) {
      for (let j = 0; j < this.rooms[i].devices.length; j += 1) {
        if (this.rooms[i].devices[j].id === deviceId) {
          return this.rooms[i].devices[j];
        }
      }
    }
    return undefined;
  }

  updateDeviceBrightness(device: DeviceInfo, value: number): void {
    this.updateDeviceStateLocal(device.id, (current: DeviceInfo): DeviceInfo => {
      return {
        id: current.id,
        type: current.type,
        name: current.name,
        power: value > 0,
        locked: current.locked,
        brightness: value,
        temperature: current.temperature,
        mode: this.normalizeType(current.type) === 'curtain'
          ? (current.mode && current.mode.length > 0 ? current.mode : '自动')
          : current.mode
      };
    });
  }

  syncDeviceBrightness(device: DeviceInfo, value: number): void {
    this.updateDeviceBrightness(device, value);
    this.requestPost('/api/device', this.createBrightnessPayload(device, value), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.markLocalDemoMode();
        return;
      }
      this.loadStatus();
    });
  }

  syncDeviceBrightnessById(deviceId: string): void {
    let currentDevice = this.findDeviceById(deviceId);
    if (!currentDevice) {
      return;
    }
    this.syncDeviceBrightness(currentDevice, this.currentDeviceBrightness(currentDevice));
  }

  syncLightBrightness(): void {
    let cards = this.deviceCardsForSelectedType();
    if (cards.length === 0) {
      return;
    }
    this.updateSelectedLightBrightnessLocal(this.lightBrightness);
    for (let i = 0; i < cards.length; i += 1) {
      this.requestPost('/api/device', this.createBrightnessPayload(cards[i].device, this.lightBrightness), (success: boolean, result: string) => {
        if (!success) {
          this.markLocalDemoMode();
          return;
        }
        let response = this.parseActionResponse(result);
        if (!response.success) {
          this.markLocalDemoMode();
        }
      });
    }
    this.loadStatus();
  }

  private updateAirStateLocal(deviceId: string, power: boolean, temperature: number, mode: string): void {
    this.airTemperature = temperature;
    this.currentAirModeText = this.normalizeAirModeValue(mode);
    this.updateDeviceStateLocal(deviceId, (current: DeviceInfo): DeviceInfo => {
      return {
        id: current.id,
        type: current.type,
        name: current.name,
        power: power,
        locked: current.locked,
        brightness: current.brightness,
        temperature: temperature,
        mode: mode
      };
    });
  }

  private syncAirState(device: DeviceInfo, power: boolean, temperature: number, mode: string): void {
    let nextTemperature = Math.max(16, Math.min(30, temperature));
    let nextMode = mode.length > 0 ? mode : this.currentAirMode(device);
    this.updateAirStateLocal(device.id, power, nextTemperature, nextMode);
    this.requestPost('/api/air', this.createAirPayload(device, power, nextTemperature, nextMode),
      (success: boolean, result: string) => {
        if (!success) {
          this.markLocalDemoMode();
          return;
        }
        let response = this.parseActionResponse(result);
        if (!response.success) {
          this.markLocalDemoMode();
          return;
        }
        this.loadStatus();
      });
  }

  private broadcastWithSpeaker(device: DeviceInfo, command: string, broadcast: string): void {
    let speakerCard = this.findDeviceCardByIdAndType(device.id, 'speaker');
    if (!speakerCard) {
      return;
    }
    let speaker = speakerCard.device;
    this.updateDeviceStateLocal(speaker.id, (current: DeviceInfo): DeviceInfo => {
      return {
        id: current.id,
        type: current.type,
        name: current.name,
        power: true,
        locked: current.locked,
        brightness: current.brightness,
        temperature: current.temperature,
        mode: current.mode,
        listening: true,
        lastCommand: command,
        lastBroadcast: broadcast,
        cleanMode: current.cleanMode,
        activityArea: current.activityArea,
        battery: current.battery,
        cleaningProgress: current.cleaningProgress
      };
    });
    this.requestPost('/api/device', this.createSpeakerBroadcastPayload(speaker, command, broadcast), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.markLocalDemoMode();
        return;
      }
      this.loadStatus();
    });
  }

  private controlSpeakerMusic(device: DeviceInfo, playing: boolean): void {
    let speakerCard = this.findDeviceCardByIdAndType(device.id, 'speaker');
    if (!speakerCard) {
      return;
    }
    let speaker = speakerCard.device;
    this.updateDeviceStateLocal(speaker.id, (current: DeviceInfo): DeviceInfo => {
      return {
        id: current.id,
        type: current.type,
        name: current.name,
        power: true,
        locked: current.locked,
        brightness: current.brightness,
        temperature: current.temperature,
        mode: current.mode,
        listening: true,
        lastCommand: playing ? '自动播放音乐' : '暂停音乐',
        lastBroadcast: playing ? '正在播放：' + (current.musicTitle || '智能音箱演示音乐') : '音乐已暂停',
        musicTrackId: current.musicTrackId || 'demo-tone',
        musicTitle: current.musicTitle || '智能音箱演示音乐',
        musicArtist: current.musicArtist,
        musicUrl: current.musicUrl,
        musicPlaying: playing,
        musicStartedAt: current.musicStartedAt,
        cleanMode: current.cleanMode,
        activityArea: current.activityArea,
        battery: current.battery,
        cleaningProgress: current.cleaningProgress
      };
    });
    this.requestPost('/api/device', this.createSpeakerMusicPayload(speaker, playing), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.markLocalDemoMode();
        return;
      }
      this.loadStatus();
    });
  }

  private controlRobot(device: DeviceInfo, power: boolean): void {
    this.updateDeviceStateLocal(device.id, (current: DeviceInfo): DeviceInfo => {
      return {
        id: current.id,
        type: current.type,
        name: current.name,
        power: power,
        locked: current.locked,
        brightness: current.brightness,
        temperature: current.temperature,
        mode: current.mode,
        listening: current.listening,
        lastCommand: current.lastCommand,
        lastBroadcast: current.lastBroadcast,
        cleanMode: 'auto',
        activityArea: current.activityArea || '客厅',
        battery: current.battery !== undefined ? current.battery : 86,
        cleaningProgress: power ? (current.cleaningProgress !== undefined ? Math.min(100, current.cleaningProgress + 18) : 18) : 0
      };
    });
    this.requestPost('/api/device', this.createRobotPayload(device, power), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.markLocalDemoMode();
        return;
      }
      this.loadStatus();
    });
  }

  private simulateVoiceInput(): void {
    this.voiceListening = true;
    let command = '我要睡觉了，把灯调暗，空调调到 26 度，门锁上';
    this.housekeeperInput = command;
    let speakers = this.allDeviceCardsByType('speaker');
    if (speakers.length > 0) {
      this.broadcastWithSpeaker(speakers[0].device, command, '已识别语音指令，正在生成调度方案');
    }
    this.housekeeperStatus = '已完成语音识别，可生成调度方案';
    this.voiceListening = false;
  }

  private changeAirTemperature(delta: number): void {
    let device = this.currentAirDevice();
    if (!device) {
      return;
    }
    let currentTemperature = this.currentAirTemperature(device);
    let nextTemperature = Math.max(16, Math.min(30, currentTemperature + delta));
    if (nextTemperature === currentTemperature) {
      return;
    }
    this.syncAirState(device, device.power, nextTemperature, this.currentAirMode(device));
  }

  private changeAirMode(mode: string): void {
    let device = this.currentAirDevice();
    if (!device) {
      return;
    }
    this.syncAirState(device, true, this.currentAirTemperature(device), mode);
  }

  private activeDeviceCount(): number {
    let count = 0;
    for (let i = 0; i < this.rooms.length; i += 1) {
      for (let j = 0; j < this.rooms[i].devices.length; j += 1) {
        let device = this.rooms[i].devices[j];
        if (this.normalizeType(device.type) === 'door') {
          if (device.locked === false) {
            count += 1;
          }
        } else if (device.power) {
          count += 1;
        }
      }
    }
    return count;
  }

  private isEmptyHome(): boolean {
    if (this.rooms.length === 0) {
      return true;
    }
    for (let i = 0; i < this.rooms.length; i += 1) {
      if (this.rooms[i].devices.length > 0) {
        return false;
      }
    }
    return true;
  }

  private defaultSceneDevicePreset(deviceId: string, deviceType: string, deviceName: string, roomName: string,
    enabled: boolean, brightness?: number, temperature?: number, mode?: string, locked?: boolean): SceneDevicePreset {
    return {
      deviceId,
      deviceType,
      deviceName,
      roomName,
      enabled,
      brightness,
      temperature,
      mode,
      locked
    };
  }

  private sceneBaseLabel(key: string): string {
    if (key === 'home') {
      return '回家模式';
    }
    if (key === 'away') {
      return '离家模式';
    }
    if (key === 'sleep') {
      return '睡眠模式';
    }
    if (key === 'energy') {
      return '节能模式';
    }
    return '自定义场景';
  }

  private allSceneDeviceCards(): DeviceCardInfo[] {
    let cards: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        let type = this.normalizeType(device.type);
        if (type === 'light' || type === 'curtain' || type === 'air' || type === 'door') {
          cards.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return cards;
  }

  private defaultSceneDevices(modeKey: string): SceneDevicePreset[] {
    let cards = this.allSceneDeviceCards();
    let presets: SceneDevicePreset[] = [];
    for (let i = 0; i < cards.length; i += 1) {
      let card = cards[i];
      let type = this.normalizeType(card.device.type);
      let enabled = false;
      let brightness: number | undefined = undefined;
      let temperature: number | undefined = undefined;
      let mode: string | undefined = undefined;
      let locked: boolean | undefined = undefined;
      if (modeKey === 'home') {
        if (type === 'light') {
          enabled = true;
          brightness = 72;
        } else if (type === 'curtain') {
          enabled = true;
          brightness = 100;
          mode = '自动';
        } else if (type === 'air') {
          enabled = true;
          temperature = 24;
          mode = '制冷';
        } else if (type === 'door') {
          enabled = true;
          locked = true;
        }
      } else if (modeKey === 'away') {
        if (type === 'light') {
          enabled = false;
          brightness = 0;
        } else if (type === 'curtain') {
          enabled = true;
          brightness = 0;
          mode = '手动';
        } else if (type === 'air') {
          enabled = false;
          temperature = 26;
          mode = '制冷';
        } else if (type === 'door') {
          enabled = true;
          locked = true;
        }
      } else if (modeKey === 'sleep') {
        if (type === 'light') {
          enabled = true;
          brightness = 20;
        } else if (type === 'curtain') {
          enabled = true;
          brightness = 0;
          mode = '睡眠';
        } else if (type === 'air') {
          enabled = true;
          temperature = 26;
          mode = '睡眠';
        } else if (type === 'door') {
          enabled = true;
          locked = true;
        }
      } else if (modeKey === 'energy') {
        if (type === 'light') {
          enabled = true;
          brightness = 35;
        } else if (type === 'curtain') {
          enabled = true;
          brightness = 40;
          mode = '节能';
        } else if (type === 'air') {
          enabled = true;
          temperature = 27;
          mode = '节能';
        } else if (type === 'door') {
          enabled = true;
          locked = true;
        }
      } else {
        if (type === 'door') {
          enabled = true;
          locked = true;
        }
      }
      presets.push(this.defaultSceneDevicePreset(
        card.device.id,
        type,
        card.device.name,
        card.roomName,
        enabled,
        brightness,
        temperature,
        mode,
        locked
      ));
    }
    return presets;
  }

  private defaultSceneMode(modeKey: string, label: string, builtIn: boolean): SceneModePreset {
    return {
      key: modeKey,
      label,
      builtIn,
      devices: this.defaultSceneDevices(modeKey)
    };
  }

  private defaultSceneConfig(): SceneConfig {
    return {
      home: this.defaultSceneMode('home', '回家模式', true),
      away: this.defaultSceneMode('away', '离家模式', true),
      sleep: this.defaultSceneMode('sleep', '睡眠模式', true),
      energy: this.defaultSceneMode('energy', '节能模式', true),
      customModes: []
    };
  }

  private cloneSceneConfig(config: SceneConfig): SceneConfig {
    return JSON.parse(JSON.stringify(config)) as SceneConfig;
  }

  private allSceneModes(): SceneModePreset[] {
    let modes: SceneModePreset[] = [
      this.sceneConfig.home,
      this.sceneConfig.away,
      this.sceneConfig.sleep,
      this.sceneConfig.energy
    ];
    if (this.sceneConfig.customModes) {
      for (let i = 0; i < this.sceneConfig.customModes.length; i += 1) {
        modes.push(this.sceneConfig.customModes[i]);
      }
    }
    return modes;
  }

  private findSceneMode(mode: string): SceneModePreset | undefined {
    let modes = this.allSceneModes();
    for (let i = 0; i < modes.length; i += 1) {
      if (modes[i].key === mode) {
        return modes[i];
      }
    }
    return undefined;
  }

  private sceneModePreset(mode: string): SceneModePreset {
    let found = this.findSceneMode(mode);
    if (found) {
      return found;
    }
    return this.sceneConfig.home;
  }

  private updateSceneModePreset(mode: string, preset: SceneModePreset): void {
    let nextConfig = this.cloneSceneConfig(this.sceneConfig);
    if (mode === 'home') {
      nextConfig.home = preset;
    } else if (mode === 'away') {
      nextConfig.away = preset;
    } else if (mode === 'sleep') {
      nextConfig.sleep = preset;
    } else if (mode === 'energy') {
      nextConfig.energy = preset;
    } else {
      let customModes = nextConfig.customModes ? nextConfig.customModes : [];
      let updated = false;
      for (let i = 0; i < customModes.length; i += 1) {
        if (customModes[i].key === mode) {
          customModes[i] = preset;
          updated = true;
          break;
        }
      }
      if (!updated) {
        customModes.push(preset);
      }
      nextConfig.customModes = customModes;
    }
    this.sceneConfig = nextConfig;
  }

  private normalizeSceneDevicePreset(raw: SceneDevicePreset, fallback?: DeviceCardInfo): SceneDevicePreset {
    let card = fallback;
    if (!card) {
      let cards = this.allSceneDeviceCards();
      for (let i = 0; i < cards.length; i += 1) {
        if (cards[i].device.id === raw.deviceId) {
          card = cards[i];
          break;
        }
      }
    }
    let type = raw.deviceType && raw.deviceType.length > 0
      ? this.normalizeType(raw.deviceType)
      : (card ? this.normalizeType(card.device.type) : 'other');
    let name = raw.deviceName && raw.deviceName.length > 0 ? raw.deviceName : (card ? card.device.name : '设备');
    let roomName = raw.roomName && raw.roomName.length > 0 ? raw.roomName : (card ? card.roomName : '未分区');
    return {
      deviceId: raw.deviceId,
      deviceType: type,
      deviceName: name,
      roomName: roomName,
      enabled: raw.enabled === true,
      brightness: type === 'light' || type === 'curtain'
        ? Math.max(0, Math.min(100, raw.brightness !== undefined ? Math.round(raw.brightness) : (raw.enabled ? 72 : 0)))
        : undefined,
      temperature: type === 'air'
        ? Math.max(16, Math.min(30, raw.temperature !== undefined ? Math.round(raw.temperature) : 26))
        : undefined,
      mode: type === 'air'
        ? (raw.mode && raw.mode.length > 0 ? raw.mode : '制冷')
        : (type === 'curtain' ? (raw.mode && raw.mode.length > 0 ? raw.mode : '自动') : undefined),
      locked: type === 'door' ? (raw.locked !== false) : undefined
    };
  }

  private normalizeSceneModePreset(raw: SceneModePreset | undefined, fallbackKey: string, fallbackLabel: string,
    builtIn: boolean): SceneModePreset {
    let base = this.defaultSceneMode(fallbackKey, fallbackLabel, builtIn);
    let cards = this.allSceneDeviceCards();
    let rawDevices = raw && Array.isArray(raw.devices) ? raw.devices : [];
    let normalizedDevices: SceneDevicePreset[] = [];
    for (let i = 0; i < cards.length; i += 1) {
      let card = cards[i];
      let matched: SceneDevicePreset | undefined = undefined;
      for (let j = 0; j < rawDevices.length; j += 1) {
        if (rawDevices[j].deviceId === card.device.id) {
          matched = rawDevices[j];
          break;
        }
      }
      if (matched) {
        normalizedDevices.push(this.normalizeSceneDevicePreset(matched, card));
      } else {
        let fallback = base.devices.find((item: SceneDevicePreset) => item.deviceId === card.device.id);
        if (fallback) {
          normalizedDevices.push(this.normalizeSceneDevicePreset(fallback, card));
        } else {
          normalizedDevices.push(this.defaultSceneDevicePreset(
            card.device.id,
            this.normalizeType(card.device.type),
            card.device.name,
            card.roomName,
            false
          ));
        }
      }
    }
    return {
      key: raw && raw.key && raw.key.length > 0 ? raw.key : fallbackKey,
      label: raw && raw.label && raw.label.length > 0 ? raw.label : fallbackLabel,
      builtIn,
      devices: normalizedDevices
    };
  }

  private legacyModeFromTypes(key: string, label: string, builtIn: boolean, types?: string[]): SceneModePreset {
    let base = this.defaultSceneMode(key, label, builtIn);
    let enabledTypes = Array.isArray(types) ? types : [];
    let devices: SceneDevicePreset[] = [];
    for (let i = 0; i < base.devices.length; i += 1) {
      let item = base.devices[i];
      let enabled = enabledTypes.indexOf(item.deviceType) >= 0;
      let nextItem = this.normalizeSceneDevicePreset({
        deviceId: item.deviceId,
        deviceType: item.deviceType,
        deviceName: item.deviceName,
        roomName: item.roomName,
        enabled: enabled,
        brightness: item.deviceType === 'light' ? (enabled ? (item.brightness !== undefined ? item.brightness : 72) : 0) : undefined,
        temperature: item.temperature,
        mode: item.mode,
        locked: item.locked
      }, undefined);
      if (item.deviceType === 'door') {
        nextItem.locked = true;
      }
      devices.push(nextItem);
    }
    return {
      key,
      label,
      builtIn,
      devices
    };
  }

  private normalizeSceneConfig(raw?: SceneConfig): SceneConfig {
    let defaults = this.defaultSceneConfig();
    if (!raw) {
      return defaults;
    }
    let legacy = raw as Object as LegacySceneConfig;
    if (legacy.homeTypes !== undefined || legacy.awayTypes !== undefined || legacy.sleepTypes !== undefined || legacy.energyTypes !== undefined) {
      return {
        home: this.legacyModeFromTypes('home', '回家模式', true, legacy.homeTypes),
        away: this.legacyModeFromTypes('away', '离家模式', true, legacy.awayTypes),
        sleep: this.legacyModeFromTypes('sleep', '睡眠模式', true, legacy.sleepTypes),
        energy: this.legacyModeFromTypes('energy', '节能模式', true, legacy.energyTypes),
        customModes: []
      };
    }
    let nextConfig: SceneConfig = {
      home: this.normalizeSceneModePreset(raw.home, 'home', '回家模式', true),
      away: this.normalizeSceneModePreset(raw.away, 'away', '离家模式', true),
      sleep: this.normalizeSceneModePreset(raw.sleep, 'sleep', '睡眠模式', true),
      energy: this.normalizeSceneModePreset(raw.energy, 'energy', '节能模式', true),
      customModes: []
    };
    let customModes = raw.customModes ? raw.customModes : [];
    for (let i = 0; i < customModes.length; i += 1) {
      let item = customModes[i];
      let safeKey = item.key && item.key.length > 0 ? item.key : 'custom_' + i.toString();
      let safeLabel = item.label && item.label.length > 0 ? item.label : ('自定义场景' + (i + 1).toString());
      nextConfig.customModes!.push(this.normalizeSceneModePreset(item, safeKey, safeLabel, false));
    }
    return nextConfig;
  }

  private sceneConfiguredCount(mode: string): number {
    let preset = this.sceneModePreset(mode);
    let count = 0;
    for (let i = 0; i < preset.devices.length; i += 1) {
      if (preset.devices[i].enabled) {
        count += 1;
      }
    }
    return count;
  }

  private sceneDevicePreset(mode: string, deviceId: string): SceneDevicePreset | undefined {
    let devices = this.sceneModePreset(mode).devices;
    for (let i = 0; i < devices.length; i += 1) {
      if (devices[i].deviceId === deviceId) {
        return devices[i];
      }
    }
    return undefined;
  }

  private sceneDeviceEnabled(mode: string, deviceId: string): boolean {
    let preset = this.sceneDevicePreset(mode, deviceId);
    if (!preset) {
      return false;
    }
    if (preset.deviceType === 'light') {
      return preset.enabled === true && (preset.brightness !== undefined ? preset.brightness > 0 : true);
    }
    return preset.enabled === true;
  }

  private sceneDeviceRenderKey(mode: string, deviceId: string): string {
    let preset = this.sceneDevicePreset(mode, deviceId);
    if (!preset) {
      return mode + '_' + deviceId + '_missing';
    }
    let brightness = preset.brightness !== undefined ? preset.brightness.toString() : 'na';
    let temperature = preset.temperature !== undefined ? preset.temperature.toString() : 'na';
    let locked = preset.locked === false ? 'unlock' : 'lock';
    return mode + '_' + deviceId + '_' + (this.sceneDeviceEnabled(mode, deviceId) ? 'on' : 'off') + '_' + brightness + '_' + temperature + '_' + locked;
  }

  private updateSceneDevicePreset(mode: string, deviceId: string, updater: (preset: SceneDevicePreset) => SceneDevicePreset): void {
    let preset = this.cloneSceneConfig(this.sceneConfig);
    let target = this.sceneModePreset(mode);
    let nextDevices: SceneDevicePreset[] = [];
    let updated = false;
    for (let i = 0; i < target.devices.length; i += 1) {
      let item = target.devices[i];
      if (item.deviceId === deviceId) {
        nextDevices.push(this.normalizeSceneDevicePreset(updater(item)));
        updated = true;
      } else {
        nextDevices.push(item);
      }
    }
    if (!updated) {
      let cards = this.allSceneDeviceCards();
      for (let i = 0; i < cards.length; i += 1) {
        if (cards[i].device.id === deviceId) {
          nextDevices.push(this.normalizeSceneDevicePreset(updater(this.defaultSceneDevicePreset(
            cards[i].device.id,
            this.normalizeType(cards[i].device.type),
            cards[i].device.name,
            cards[i].roomName,
            false
          )), cards[i]));
          break;
        }
      }
    }
    this.updateSceneModePreset(mode, {
      key: target.key,
      label: target.label,
      builtIn: target.builtIn,
      devices: nextDevices
    });
  }

  private updateSceneDeviceEnabled(mode: string, deviceId: string, enabled: boolean): void {
    this.updateSceneDevicePreset(mode, deviceId, (preset: SceneDevicePreset) => {
      let nextPreset: SceneDevicePreset = {
        deviceId: preset.deviceId,
        deviceType: preset.deviceType,
        deviceName: preset.deviceName,
        roomName: preset.roomName,
        enabled: preset.enabled,
        brightness: preset.brightness,
        temperature: preset.temperature,
        mode: preset.mode,
        locked: preset.locked
      };
      nextPreset.enabled = enabled;
      if (nextPreset.deviceType === 'light') {
        nextPreset.brightness = enabled ? (nextPreset.brightness !== undefined ? nextPreset.brightness : 72) : 0;
      } else if (nextPreset.deviceType === 'air') {
        nextPreset.temperature = nextPreset.temperature !== undefined ? nextPreset.temperature : 26;
        nextPreset.mode = nextPreset.mode && nextPreset.mode.length > 0 ? nextPreset.mode : '制冷';
      } else if (nextPreset.deviceType === 'door') {
        nextPreset.locked = true;
      }
      return nextPreset;
    });
  }

  private updateSceneLightBrightness(mode: string, deviceId: string, brightness: number): void {
    this.updateSceneDevicePreset(mode, deviceId, (preset: SceneDevicePreset) => {
      let nextPreset: SceneDevicePreset = {
        deviceId: preset.deviceId,
        deviceType: preset.deviceType,
        deviceName: preset.deviceName,
        roomName: preset.roomName,
        enabled: preset.enabled,
        brightness: preset.brightness,
        temperature: preset.temperature,
        mode: preset.mode,
        locked: preset.locked
      };
      nextPreset.brightness = Math.max(0, Math.min(100, Math.round(brightness)));
      nextPreset.enabled = nextPreset.brightness > 0;
      return nextPreset;
    });
  }

  private updateSceneAirTemperature(mode: string, deviceId: string, delta: number): void {
    this.updateSceneDevicePreset(mode, deviceId, (preset: SceneDevicePreset) => {
      let nextPreset: SceneDevicePreset = {
        deviceId: preset.deviceId,
        deviceType: preset.deviceType,
        deviceName: preset.deviceName,
        roomName: preset.roomName,
        enabled: preset.enabled,
        brightness: preset.brightness,
        temperature: preset.temperature,
        mode: preset.mode,
        locked: preset.locked
      };
      let currentTemperature = nextPreset.temperature !== undefined ? nextPreset.temperature : 26;
      nextPreset.temperature = Math.max(16, Math.min(30, currentTemperature + delta));
      nextPreset.enabled = true;
      return nextPreset;
    });
  }

  private updateSceneAirMode(mode: string, deviceId: string, nextMode: string): void {
    this.updateSceneDevicePreset(mode, deviceId, (preset: SceneDevicePreset) => {
      let nextPreset: SceneDevicePreset = {
        deviceId: preset.deviceId,
        deviceType: preset.deviceType,
        deviceName: preset.deviceName,
        roomName: preset.roomName,
        enabled: preset.enabled,
        brightness: preset.brightness,
        temperature: preset.temperature,
        mode: preset.mode,
        locked: preset.locked
      };
      nextPreset.mode = nextMode;
      nextPreset.enabled = true;
      return nextPreset;
    });
  }

  private resetAddSceneModeDialog(): void {
    this.sceneModeDraftName = '';
  }

  private sanitizeSceneModeKey(label: string): string {
    let trimmed = label.trim();
    let key = '';
    for (let i = 0; i < trimmed.length; i += 1) {
      let code = trimmed.charCodeAt(i);
      if ((code >= 48 && code <= 57) || (code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        key += trimmed.charAt(i).toLowerCase();
      } else if (trimmed.charAt(i) === ' ' || trimmed.charAt(i) === '-' || trimmed.charAt(i) === '_') {
        if (key.length > 0 && key.charAt(key.length - 1) !== '_') {
          key += '_';
        }
      }
    }
    if (key.length === 0) {
      key = 'scene_' + Date.now().toString();
    }
    return 'custom_' + key;
  }

  private addSceneMode(): void {
    let label = this.sceneModeDraftName.trim();
    if (label.length === 0) {
      this.showDialog('请输入场景模式名称');
      return;
    }
    let key = this.sanitizeSceneModeKey(label);
    if (this.findSceneMode(key)) {
      key = key + '_' + Date.now().toString().slice(-4);
    }
    let nextConfig = this.cloneSceneConfig(this.sceneConfig);
    let customModes = nextConfig.customModes ? nextConfig.customModes : [];
    customModes.push(this.defaultSceneMode(key, label, false));
    nextConfig.customModes = customModes;
    this.sceneConfig = nextConfig;
    this.selectedSceneMode = key;
    this.showAddSceneModeDialog = false;
    this.showSceneDialog = true;
    this.resetAddSceneModeDialog();
  }

  private sceneLightBrightness(mode: string, deviceId: string): number {
    let preset = this.sceneDevicePreset(mode, deviceId);
    let value = preset ? preset.brightness : undefined;
    return value !== undefined ? value : 72;
  }

  private sceneAirTemperature(mode: string, deviceId: string): number {
    let preset = this.sceneDevicePreset(mode, deviceId);
    let value = preset ? preset.temperature : undefined;
    return value !== undefined ? value : 26;
  }

  private sceneAirModeText(mode: string, deviceId: string): string {
    let preset = this.sceneDevicePreset(mode, deviceId);
    let value = preset ? preset.mode : undefined;
    return value && value.length > 0 ? value : '制冷';
  }

  private resetAddDeviceDialog(): void {
    this.modalDeviceName = '';
    this.modalRoomName = '';
    this.modalDeviceType = 'light';
  }

  login(): void {
    if (this.username.trim().length === 0) {
      this.showDialog('请输入用户名');
      return;
    }
    if (this.password.trim().length === 0) {
      this.showDialog('请输入密码');
      return;
    }

    this.requestPost('/api/login', this.createAuthPayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('连接后端失败，请稍后重试');
        return;
      }

      let response = this.parseAuthResponse(result);
      if (!response.success) {
        this.showDialog('用户名或密码错误，请重新输入');
        return;
      }

      this.currentUser = response.username ? response.username : this.username.trim();
      this.isLoggedIn = true;
      this.startStatusRefresh();
      this.loadStatus();
    });
  }

  register(): void {
    if (this.username.trim().length === 0) {
      this.showDialog('请输入用户名');
      return;
    }
    if (this.password.trim().length === 0) {
      this.showDialog('请输入密码');
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.showDialog('两次输入的密码不一致');
      return;
    }

    this.requestPost('/api/register', this.createAuthPayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('连接后端失败，请稍后重试');
        return;
      }

      let response = this.parseAuthResponse(result);
      if (!response.success) {
        this.showDialog(response.message);
        return;
      }

      this.showDialog('注册成功，请登录');
      this.isRegisterMode = false;
      this.password = '';
      this.confirmPassword = '';
    });
  }

  loadStatus(): void {
    this.requestGet('/api/status' + this.usernameQuery(), (success: boolean, result: string) => {
      if (!success) {
      this.syncMessage = '获取状态失败';
        return;
      }

      let response = this.parseStatusResponse(result);
      if (!response.success) {
        this.syncMessage = '状态同步失败';
        return;
      }

      this.homeName = this.currentUser.length > 0 ? this.currentUser + '的家' : this.normalizeDisplayText(response.data.homeName);
      this.currentMode = response.data.mode;
      this.storageMode = response.storage;
      this.updatedAt = response.data.updatedAt;
      if (this.visibleTypeKeys().indexOf(this.selectedType) < 0) {
        this.selectType('door');
      }
      this.rooms = response.data.rooms;
      this.ensureValidRoomFilter();
      let normalizedLogs: LogInfo[] = [];
      for (let i = 0; i < response.data.logs.length; i += 1) {
        let item = response.data.logs[i];
        let normalizedItem: LogInfo = {
          id: item.id,
          time: item.time,
          action: item.action,
          target: this.normalizeDisplayText(item.target),
          detail: this.normalizeDisplayText(item.detail)
        };
        normalizedLogs.push(normalizedItem);
      }
      this.logs = normalizedLogs;
      if (response.data.utilityAccount) {
        this.utilityAccount = response.data.utilityAccount;
      } else {
        this.utilityAccount = { electricBalance: 0, gasBalance: 0, waterBalance: 0 };
      }
      this.familyMembers = response.data.familyMembers ? response.data.familyMembers : [];
      if (response.data.environment) {
        this.currentTemperatureText = response.data.environment.temperature.toString() + '℃';
        this.currentHumidityText = response.data.environment.humidity.toString() + '%';
      } else {
        this.currentTemperatureText = '--';
        this.currentHumidityText = '--';
      }
      if (this.selectedType === 'light') {
        this.currentLightBrightness();
      }
      if (this.selectedType === 'air') {
        let currentAir = this.currentAirDevice();
        this.currentAirModeText = currentAir ? this.normalizeAirModeValue(currentAir.mode) : '制冷';
      }
      if (!this.showSceneDialog && !this.showAddSceneModeDialog) {
        this.sceneConfig = this.normalizeSceneConfig(response.data.sceneConfig);
        if (this.findSceneMode(this.selectedSceneMode) === undefined) {
          if (response.data.mode && this.findSceneMode(response.data.mode) !== undefined) {
            this.selectedSceneMode = response.data.mode;
          } else {
            this.selectedSceneMode = this.sceneConfig.home.key;
          }
        } else if (!response.data.mode && this.findSceneMode(this.selectedSceneMode) === undefined) {
          this.selectedSceneMode = this.sceneConfig.home.key;
        }
      }
    this.syncMessage = '已同步后端状态';
    });
  }

  controlRoomType(roomName: string, power: boolean): void {
    this.updateSelectedTypeDevicesLocal(power, roomName);
    this.requestPost('/api/type-control', this.createTypeControlPayload(power, roomName), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.loadStatus();
        return;
      }
      this.markLocalDemoMode();
    });
  }

  controlAllType(power: boolean): void {
    if (this.selectedRoomFilter !== '全部') {
      this.controlRoomType(this.selectedRoomFilter, power);
      return;
    }
    this.updateSelectedTypeDevicesLocal(power);
    this.requestPost('/api/type-control', this.createTypeControlPayload(power), (success: boolean, result: string) => {
      if (!success) {
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.loadStatus();
        return;
      }
      this.markLocalDemoMode();
    });
  }

  applyAwayMode(): void {
    this.requestPost('/api/scene/apply', this.createSceneApplyPayload('away'), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('离家模式执行失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.currentMode = 'away';
        this.loadStatus();
      }
    });
  }

  applyHomeMode(): void {
    this.requestPost('/api/scene/apply', this.createSceneApplyPayload('home'), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('回家模式执行失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.currentMode = 'home';
        this.loadStatus();
      }
    });
  }

  saveScenePreset(): void {
    this.requestPost('/api/scene-config', this.createSceneConfigPayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('保存预设失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.showSceneDialog = false;
        this.showDialog('场景预设已保存');
        this.loadStatus();
      }
    });
  }

  private runSceneMode(mode: string): void {
    this.requestPost('/api/scene/apply', this.createSceneApplyPayload(mode), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog(this.sceneModeLabel(mode) + '执行失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (response.success) {
        this.currentMode = mode;
        this.selectedSceneMode = mode;
        this.loadStatus();
      }
    });
  }

  addDevice(): void {
    if (this.modalDeviceName.trim().length === 0) {
      this.showDialog('请输入设备名称');
      return;
    }
    if (this.modalRoomName.trim().length === 0) {
      this.showDialog('请输入房间名称');
      return;
    }

    this.requestPost('/api/devices', this.createAddDevicePayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('添加设备失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.showDialog(response.message ? response.message : '添加设备失败，请检查后端是否已经重启');
        return;
      }
      this.selectType(this.modalDeviceType);
      this.showAddDeviceDialog = false;
      this.showAddMenuDialog = false;
      this.resetAddDeviceDialog();
      this.loadStatus();
    });
  }

  private utilityLabel(type: string): string {
    if (type === 'gas') {
      return '燃气费';
    }
    if (type === 'water') {
      return '水费';
    }
    return '电费';
  }

  private utilityBalance(type: string): string {
    if (type === 'gas') {
      return this.utilityAccount.gasBalance.toFixed(2);
    }
    if (type === 'water') {
      return this.utilityAccount.waterBalance.toFixed(2);
    }
    return this.utilityAccount.electricBalance.toFixed(2);
  }

  private utilityQuickSet(amount: number): void {
    this.utilityRechargeAmount = amount.toString();
  }

  private rechargeUtility(): void {
    let amount = Number.parseFloat(this.utilityRechargeAmount);
    if (!Number.isFinite(amount) || amount <= 0) {
      this.showDialog('请输入正确的充值金额');
      return;
    }
    this.requestPost('/api/utility/recharge', this.createUtilityRechargePayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('生活缴费充值失败');
        return;
      }
      let response = this.parseUtilityRechargeResponse(result);
      if (!response.success) {
        this.showDialog(response.message ? response.message : '生活缴费充值失败');
        return;
      }
      this.utilityRechargeAmount = '';
      this.showUtilityDialog = false;
      this.showDialog(this.utilityLabel(this.selectedUtilityType) + '充值成功');
      this.loadStatus();
    });
  }

  private addFamilyMemberFromDialog(): void {
    if (this.familyMemberName.trim().length === 0) {
      this.showDialog('请输入家人姓名');
      return;
    }
    if (this.familyMemberPhone.trim().length !== 11) {
      this.showDialog('请输入 11 位手机号');
      return;
    }
    this.requestPost('/api/family-members', this.createFamilyMemberPayload(), (success: boolean, result: string) => {
      if (!success) {
        this.showDialog('添加家人失败');
        return;
      }
      let response = this.parseActionResponse(result);
      if (!response.success) {
        this.showDialog(response.message ? response.message : '添加家人失败');
        return;
      }
      this.familyMemberName = '';
      this.familyMemberPhone = '';
      this.showFamilyDialog = false;
      this.showDialog('家人已加入家庭管理');
      this.loadStatus();
    });
  }

  logout(): void {
    this.stopStatusRefresh();
    this.isLoggedIn = false;
    this.password = '';
    this.confirmPassword = '';
    this.currentUser = '';
    this.rooms = [];
    this.logs = [];
    this.homeName = '我的家';
    this.currentMode = 'home';
    this.storageMode = '--';
    this.updatedAt = '--';
    this.currentTemperatureText = '--';
    this.currentHumidityText = '--';
    this.selectedType = 'door';
    this.selectedRoomFilter = '全部';
    this.syncMessage = '等待同步';
    this.housekeeperInput = '';
    this.housekeeperSelectedPreset = '';
    this.housekeeperPlan = null;
    this.housekeeperStatus = '等待生成调度方案';
    this.housekeeperExecutionTitle = '';
    this.housekeeperExecutionLines = [];
    this.housekeeperExecuting = false;
    this.showAddMenuDialog = false;
    this.showAddDeviceDialog = false;
    this.showSceneDialog = false;
    this.showAddSceneModeDialog = false;
    this.showDoorUnlockDialog = false;
    this.showUtilityDialog = false;
    this.showFamilyDialog = false;
    this.doorUnlockDeviceId = '';
    this.doorUnlockPin = '';
    this.utilityAccount = { electricBalance: 0, gasBalance: 0, waterBalance: 0 };
    this.familyMembers = [];
    this.selectedUtilityType = 'electric';
    this.utilityRechargeAmount = '';
    this.familyMemberName = '';
    this.familyMemberPhone = '';
    this.resetAddDeviceDialog();
    this.resetAddSceneModeDialog();
  }

  private showLearnHongju(): void {
    this.showDialog('鸿居智控是一个面向 OpenHarmony 的智能家居设备控制系统，可统一管理房间、灯光、空调、门禁等设备。');
  }

  private currentEnvironmentTemperature(): number {
    if (this.currentTemperatureText.indexOf('°C') > 0) {
      return Number.parseInt(this.currentTemperatureText, 10);
    }
    return 26;
  }

  private currentEnvironmentHumidity(): number {
    if (this.currentHumidityText.indexOf('%') > 0) {
      return Number.parseInt(this.currentHumidityText, 10);
    }
    return 55;
  }

  private allLights(): DeviceCardInfo[] {
    let list: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (this.normalizeType(device.type) === 'light') {
          list.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return list;
  }

  private allCurtains(): DeviceCardInfo[] {
    let list: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (this.normalizeType(device.type) === 'curtain') {
          list.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return list;
  }

  private allDoors(): DeviceCardInfo[] {
    let list: DeviceCardInfo[] = [];
    for (let i = 0; i < this.rooms.length; i += 1) {
      let room = this.rooms[i];
      for (let j = 0; j < room.devices.length; j += 1) {
        let device = room.devices[j];
        if (this.normalizeType(device.type) === 'door') {
          list.push({
            roomId: room.id,
            roomName: this.displayRoomName(room.name),
            device: device
          });
        }
      }
    }
    return list;
  }

  private firstDoorDevice(): DeviceInfo | undefined {
    let doors = this.allDoors();
    if (doors.length === 0) {
      return undefined;
    }
    return doors[0].device;
  }

  private housekeeperIntentLabel(intent: string): string {
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

  private containsHousekeeperKeyword(text: string, keywords: string[]): boolean {
    let lower = text.toLowerCase();
    for (let i = 0; i < keywords.length; i += 1) {
      let keyword = keywords[i];
      if (keyword.length === 0) {
        continue;
      }
      let useLower = false;
      for (let j = 0; j < keyword.length; j += 1) {
        let code = keyword.charCodeAt(j);
        if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
          useLower = true;
          break;
        }
      }
      if (useLower) {
        if (lower.indexOf(keyword.toLowerCase()) >= 0) {
          return true;
        }
      } else if (text.indexOf(keyword) >= 0) {
        return true;
      }
    }
    return false;
  }

  private matchHousekeeperIntent(input: string): string {
    let text = input.trim();
    let musicKeywords: string[] = ['音乐', '播放', '听歌', '放歌', '播歌', '歌曲', '歌单', 'bgm', 'music', 'play', 'song', 'audio'];
    let cleanKeywords: string[] = ['扫地', '打扫', '清扫', '清洁', '搞卫生', '做卫生', '卫生', '拖地', '吸尘', '机器人', '扫地机', 'vacuum', 'clean', 'sweep', 'robot'];
    let elderKeywords: string[] = ['老人', '长辈', '70岁', '舒适', 'elder', 'old', 'senior', 'comfort'];
    let sleepKeywords: string[] = ['睡', '休息', '夜间', '睡眠', '入睡', '晚安', 'sleep', 'rest', 'night', 'bedtime'];
    let awayKeywords: string[] = ['出门', '离家', '外出', '安全', '防盗', 'away', 'leave', 'out', 'safe', 'security'];
    let energyKeywords: string[] = ['省电', '节能', '省能', '低耗', 'save power', 'energy', 'eco'];

    if (this.containsHousekeeperKeyword(text, musicKeywords) && this.containsHousekeeperKeyword(text, cleanKeywords)) {
      return 'music_clean';
    }
    if (this.containsHousekeeperKeyword(text, elderKeywords)) {
      return 'elder_comfort';
    }
    if (this.containsHousekeeperKeyword(text, sleepKeywords)) {
      return 'sleep_mode';
    }
    if (this.containsHousekeeperKeyword(text, awayKeywords)) {
      return 'away_safe';
    }
    if (this.containsHousekeeperKeyword(text, energyKeywords)) {
      return 'energy_save';
    }
    return '';
  }

  private detectHousekeeperIntent(input: string): string {
    let matched = this.matchHousekeeperIntent(input);
    return matched.length > 0 ? matched : 'elder_comfort';
  }

  private createHousekeeperPlan(intent: string): HousekeeperPlan {
    let actions: HousekeeperAction[] = [];
    let temperature = this.currentEnvironmentTemperature();
    let humidity = this.currentEnvironmentHumidity();
    let lights = this.allLights();
    let curtains = this.allCurtains();
    let airDevice = this.currentAirDevice();
    let doorDevice = this.firstDoorDevice();
    let speakers = this.allDeviceCardsByType('speaker');
    let robots = this.allDeviceCardsByType('robot');
    if (intent === 'music_clean') {
      actions.push({
        key: 'speaker',
        deviceType: 'speaker',
        title: '音箱',
        detail: speakers.length > 0 ? '播放音乐，营造轻松居家氛围' : '当前未接入智能音箱设备',
        reason: '先启动音乐播放，增强居家体验',
        power: speakers.length > 0
      });
      actions.push({
        key: 'robot',
        deviceType: 'robot',
        title: '扫地机器人',
        detail: robots.length > 0 ? '启动扫地机器人，开始打扫卫生' : '当前未接入扫地机器人设备',
        reason: '同步开始地面清扫，完成家务联动',
        power: robots.length > 0
      });
      return {
        intent: intent,
        intentLabel: this.housekeeperIntentLabel(intent),
        summary: '已生成播放音乐并启动扫地机器人的协同方案',
        messageToUser: '已生成音乐清扫模式，是否一键执行？',
        needConfirm: true,
        actions: actions
      };
    }
    if (intent === 'sleep_mode') {
      actions.push({
        key: 'light',
        deviceType: 'light',
        title: '灯光',
        detail: lights.length > 0 ? '关闭主照明，保留 20% 低亮度过道灯' : '当前未接入灯光设备',
        reason: '减少眩光，帮助休息',
        power: lights.length > 0,
        brightness: lights.length > 0 ? 20 : 0
      });
      actions.push({
        key: 'curtain',
        deviceType: 'curtain',
        title: '窗帘',
        detail: curtains.length > 0 ? '关闭卧室窗帘，减少夜间光线干扰' : '当前未接入窗帘设备',
        reason: '营造更安静的睡眠光环境',
        power: curtains.length > 0,
        brightness: 0,
        mode: '睡眠'
      });
      actions.push({
        key: 'air',
        deviceType: 'air',
        title: '空调',
        detail: airDevice ? '开启睡眠模式，目标温度 25°C' : '当前未接入空调设备',
        reason: '维持更安静舒适的睡眠环境',
        power: airDevice !== undefined,
        temperature: 25,
        mode: '睡眠'
      });
      actions.push({
        key: 'door',
        deviceType: 'door',
        title: '门禁',
        detail: doorDevice ? '保持上锁，夜间持续防护' : '当前未接入门禁设备',
        reason: '保障夜间安全',
        locked: true
      });
      return {
        intent: intent,
        intentLabel: this.housekeeperIntentLabel(intent),
        summary: '已为休息场景生成静音睡眠调度方案',
        messageToUser: '已生成睡眠模式，是否执行？',
        needConfirm: true,
        actions: actions
      };
    }
    if (intent === 'away_safe') {
      actions.push({
        key: 'light',
        deviceType: 'light',
        title: '灯光',
        detail: lights.length > 0 ? '关闭全屋灯光，避免无效耗电' : '当前未接入灯光设备',
        reason: '离家后降低能耗',
        power: false,
        brightness: 0
      });
      actions.push({
        key: 'curtain',
        deviceType: 'curtain',
        title: '窗帘',
        detail: curtains.length > 0 ? '关闭全屋窗帘，保护隐私并减少日晒' : '当前未接入窗帘设备',
        reason: '离家后保持遮阳与室内私密性',
        power: curtains.length > 0,
        brightness: 0,
        mode: '手动'
      });
      actions.push({
        key: 'air',
        deviceType: 'air',
        title: '空调',
        detail: airDevice ? '关闭空调，保留传感器监测' : '当前未接入空调设备',
        reason: '离家场景优先节能',
        power: false,
        temperature: airDevice && airDevice.temperature !== undefined ? airDevice.temperature : 28,
        mode: airDevice && airDevice.mode ? airDevice.mode : '制冷'
      });
      actions.push({
        key: 'door',
        deviceType: 'door',
        title: '门禁',
        detail: doorDevice ? '执行一键上锁，保持入户安全' : '当前未接入门禁设备',
        reason: '外出时保持安防闭环',
        locked: true
      });
      return {
        intent: intent,
        intentLabel: this.housekeeperIntentLabel(intent),
        summary: '已为离家场景生成安全防护方案',
        messageToUser: '已生成离家安全模式，是否执行？',
        needConfirm: true,
        actions: actions
      };
    }
    if (intent === 'energy_save') {
      actions.push({
        key: 'light',
        deviceType: 'light',
        title: '灯光',
        detail: lights.length > 0 ? '仅保留必要照明，亮度调整到 35%' : '当前未接入灯光设备',
        reason: '在舒适和节能之间做平衡',
        power: lights.length > 0,
        brightness: lights.length > 0 ? 35 : 0
      });
      actions.push({
        key: 'curtain',
        deviceType: 'curtain',
        title: '窗帘',
        detail: curtains.length > 0 ? '保留 40% 开合度，降低直射热负荷' : '当前未接入窗帘设备',
        reason: '减少空调负载，提升节能效果',
        power: curtains.length > 0,
        brightness: 40,
        mode: '节能'
      });
      actions.push({
        key: 'air',
        deviceType: 'air',
        title: '空调',
        detail: airDevice ? `开启节能运行，目标温度 ${temperature >= 29 ? 27 : 26}°C` : '当前未接入空调设备',
        reason: '避免过度制冷造成额外耗电',
        power: airDevice !== undefined,
        temperature: temperature >= 29 ? 27 : 26,
        mode: '除湿'
      });
      actions.push({
        key: 'door',
        deviceType: 'door',
        title: '门禁',
        detail: doorDevice ? '保持上锁，门禁维持当前安全状态' : '当前未接入门禁设备',
        reason: '安防不参与节能削减',
        locked: true
      });
      return {
        intent: intent,
        intentLabel: this.housekeeperIntentLabel(intent),
        summary: '已生成以节能优先的协同调度方案',
        messageToUser: '已生成节能模式，是否执行？',
        needConfirm: true,
        actions: actions
      };
    }

    actions.push({
      key: 'light',
      deviceType: 'light',
      title: '灯光',
      detail: lights.length > 0 ? '开启全屋柔和照明，亮度 70%' : '当前未接入灯光设备',
      reason: '老人活动时需要更均匀柔和的光线',
      power: lights.length > 0,
      brightness: lights.length > 0 ? 70 : 0
    });
    actions.push({
      key: 'curtain',
      deviceType: 'curtain',
      title: '窗帘',
      detail: curtains.length > 0 ? '调整到 60% 开合度，避免强光直射' : '当前未接入窗帘设备',
      reason: '保留柔和采光，照顾老人休息舒适度',
      power: curtains.length > 0,
      brightness: 60,
      mode: '自动'
    });
    actions.push({
      key: 'air',
      deviceType: 'air',
      title: '空调',
      detail: airDevice ? `开启空调，设置 26°C，当前环境 ${temperature}°C / ${humidity}%` : '当前未接入空调设备',
      reason: '将室内温湿度调整到更舒适的休息状态',
      power: airDevice !== undefined,
      temperature: 26,
      mode: '制冷'
    });
    actions.push({
      key: 'door',
      deviceType: 'door',
      title: '门禁',
      detail: doorDevice ? '保持上锁，继续守护家庭安全' : '当前未接入门禁设备',
      reason: '老人独处时优先保证门禁安全',
      locked: true
    });
    return {
      intent: intent,
      intentLabel: this.housekeeperIntentLabel(intent),
      summary: '已为老人舒适场景生成全屋调度方案',
      messageToUser: '已生成老人舒适模式，是否一键执行？',
      needConfirm: true,
      actions: actions
    };
  }

  private useHousekeeperPreset(option: HousekeeperPresetOption): void {
    this.housekeeperSelectedPreset = option.key;
    this.housekeeperInput = option.prompt;
    this.housekeeperStatus = '已填入快捷指令，点击生成调度方案';
  }

  private resetHousekeeperRunState(keepPlan: boolean): void {
    if (!keepPlan) {
      this.housekeeperPlan = null;
    }
    this.housekeeperExecutionTitle = '';
    this.housekeeperExecutionLines = [];
    this.housekeeperExecuting = false;
  }

  private generateHousekeeperPlan(): void {
    let input = this.housekeeperInput.trim();
    if (input.length === 0) {
      this.showDialog('请输入你的调度需求');
      return;
    }
    this.resetHousekeeperRunState(false);
    this.housekeeperStatus = '正在生成 AI 调度方案...';
    this.requestPost('/api/ai/housekeeper', this.createHousekeeperPlanPayload(), (success: boolean, result: string) => {
      if (!success) {
        let fallbackIntent = this.detectHousekeeperIntent(input);
        this.housekeeperSelectedPreset = fallbackIntent;
        this.housekeeperPlan = this.createHousekeeperPlan(fallbackIntent);
        this.housekeeperStatus = this.housekeeperPlan.messageToUser + '（当前为本地兜底方案）';
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseHousekeeperPlanResponse(result);
      if (!response.success || !response.plan) {
        let fallbackIntent = this.detectHousekeeperIntent(input);
        this.housekeeperSelectedPreset = fallbackIntent;
        this.housekeeperPlan = this.createHousekeeperPlan(fallbackIntent);
        this.housekeeperStatus = this.housekeeperPlan.messageToUser + '（当前为本地兜底方案）';
        return;
      }
      this.housekeeperPlan = response.plan;
      this.housekeeperSelectedPreset = response.plan.intent;
      this.housekeeperStatus = response.plan.messageToUser;
    });
  }

  private rerunHousekeeperPlan(): void {
    this.resetHousekeeperRunState(false);
    this.generateHousekeeperPlan();
  }

  /*
  private sceneModeLabelLegacy(mode: string): string {
    if (mode === 'home') {
      return '鍥炲妯″紡';
    }
    if (mode === 'sleep') {
      return '鐫＄湢妯″紡';
    }
    if (mode === 'energy') {
      return '鑺傝兘妯″紡';
    }
    return '绂诲妯″紡';
  }

  private sceneModeSummaryLegacy(mode: string): string {
    if (mode === 'home') {
      return '寮€鐏?路 绌鸿皟 24鈩?路 闂ㄧ涓婇攣';
    }
    if (mode === 'sleep') {
      return '鐏厜 20% 路 绌鸿皟 26鈩?路 涓婇攣';
    }
    if (mode === 'energy') {
      return '鐏厜 35% 路 绌鸿皟 27鈩?路 闂ㄧ涓婇攣';
    }
    return '鍏崇伅 路 鍏崇┖璋?路 闂ㄧ涓婇攣';
  }

  private sceneModeDetailLegacy(mode: string): string {
    if (mode === 'home') {
      return '閫傚悎鍥炲鍚庣殑鑸掗€傜幆澧?;
    }
    if (mode === 'sleep') {
      return '澶滈棿鑸掗€備笌瀹夊叏鍏奸【';
    }
    if (mode === 'energy') {
      return '鍦ㄨ垝閫傚墠鎻愪笅闄嶄綆鑳借€?;
    }
    return '闄嶄綆鑳借€楀苟淇濋殰鍏ユ埛瀹夊叏';
  }

  private sceneModeActionsLegacy(mode: string): string[] {
    let preset = this.sceneModePreset(mode);
    let actions: string[] = [];
    actions.push('门禁：' + (preset.door.enabled ? '保持上锁' : '不联动'));
    if (preset.light.enabled) {
      actions.push('灯光：开启，亮度 ' + (preset.light.brightness !== undefined ? preset.light.brightness : 72) + '%');
    } else {
      actions.push('灯光：关闭');
    }
    if (preset.air.enabled) {
      let temp = preset.air.temperature !== undefined ? preset.air.temperature : 26;
      let airMode = preset.air.mode && preset.air.mode.length > 0 ? preset.air.mode : '制冷';
      actions.push('空调：开启，' + temp.toString() + '℃ · ' + airMode);
    } else {
      actions.push('空调：关闭');
    }
    return actions;
  }

  private sceneModeAccent(mode: string): string {
    if (mode === 'home') {
      return '#7FAED6';
    }
    if (mode === 'sleep') {
      return '#6C7A92';
    }
    if (mode === 'energy') {
      return '#33A37A';
    }
    return '#485D77';
  }

  private applySceneMode(mode: string): void {
    this.selectedSceneMode = mode;
    this.runSceneMode(mode);
  }

  private sceneCurrentModeSummaryLegacy(mode: string): string {
    if (mode === 'home') {
      return '闂ㄧ宸蹭笂閿?路 鐏厜宸插紑鍚?路 绌鸿皟宸插紑鍚?;
    }
    if (mode === 'sleep') {
      return '闂ㄧ宸蹭笂閿?路 鐏厜鏌斿拰 路 绌鸿皟 26鈩?;
    }
    if (mode === 'energy') {
      return '闂ㄧ宸蹭笂閿?路 鐏厜浣庤€?路 绌鸿皟鑺傝兘';
    }
    return '闂ㄧ宸蹭笂閿?路 鐏厜宸插叧闂?路 绌鸿皟宸插叧闂?;
  }
  */

  private sceneModeLabel(mode: string): string {
    let preset = this.findSceneMode(mode);
    if (preset && preset.label.length > 0) {
      return preset.label;
    }
    return this.sceneBaseLabel(mode);
  }

  private sceneModeSummary(mode: string): string {
    let actions = this.sceneModeActions(mode);
    if (actions.length === 0) {
      return '暂未配置设备联动';
    }
    let summary = '';
    let maxCount = actions.length > 3 ? 3 : actions.length;
    for (let i = 0; i < maxCount; i += 1) {
      if (summary.length > 0) {
        summary += ' · ';
      }
      let splitIndex: number = actions[i].indexOf('：');
      summary += splitIndex > 0 ? actions[i].substring(0, splitIndex) : actions[i];
    }
    return summary;
  }

  private sceneModeDetail(mode: string): string {
    if (mode === 'home') {
      return '适合回家后的舒适环境';
    }
    if (mode === 'sleep') {
      return '夜间舒适与安全兼顾';
    }
    if (mode === 'energy') {
      return '在舒适前提下降低能耗';
    }
    if (mode === 'away') {
      return '降低能耗并保障入户安全';
    }
    return '自定义房间与设备联动规则';
  }

  private sceneModeActions(mode: string): string[] {
    let preset = this.sceneModePreset(mode);
    let actions: string[] = [];
    for (let i = 0; i < preset.devices.length; i += 1) {
      let item = preset.devices[i];
      if (item.deviceType === 'light') {
        actions.push(item.roomName + ' ' + item.deviceName + '：' + (item.enabled
          ? ('开启，亮度 ' + (item.brightness !== undefined ? item.brightness : 72).toString() + '%')
          : '关闭'));
      } else if (item.deviceType === 'curtain') {
        let curtainMode = item.mode && item.mode.length > 0 ? item.mode : '自动';
        actions.push(item.roomName + ' ' + item.deviceName + '：' + (item.enabled
          ? ('开启，开合度 ' + (item.brightness !== undefined ? item.brightness : 60).toString() + '% · ' + curtainMode)
          : '关闭'));
      } else if (item.deviceType === 'air') {
        let airMode = item.mode && item.mode.length > 0 ? item.mode : '制冷';
        actions.push(item.roomName + ' ' + item.deviceName + '：' + (item.enabled
          ? ('开启，' + (item.temperature !== undefined ? item.temperature : 26).toString() + '°C · ' + airMode)
          : '关闭'));
      } else if (item.deviceType === 'door') {
        actions.push(item.roomName + ' ' + item.deviceName + '：' + (item.enabled ? '保持上锁' : '不联动'));
      }
    }
    if (actions.length === 0) {
      actions.push('暂未配置设备联动');
    }
    return actions;
  }

  private sceneCurrentModeSummary(mode: string): string {
    return this.sceneModeSummary(mode);
  }

  private sceneModeAccent(mode: string): string {
    if (mode === 'home') {
      return '#7FAED6';
    }
    if (mode === 'sleep') {
      return '#6C7A92';
    }
    if (mode === 'energy') {
      return '#33A37A';
    }
    return '#485D77';
  }

  private applySceneMode(mode: string): void {
    this.selectedSceneMode = mode;
    this.runSceneMode(mode);
  }

  @Builder
  SceneInfoCard(mode: string) {
    Column({ space: 10 }) {
      Text(this.sceneModeLabel(mode))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
        .width('100%')
      Text(this.sceneModeSummary(mode))
        .fontSize(14)
        .fontColor('#485D77')
        .width('100%')
      Text(this.sceneModeDetail(mode))
        .fontSize(12)
        .fontColor('#7A8494')
        .width('100%')
      Row() {
        Blank()
        Button('执行')
          .height(38)
          .padding({ left: 18, right: 18 })
          .borderRadius(14)
          .backgroundColor(this.sceneModeAccent(mode))
          .fontColor('#FFFFFF')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.applySceneMode(mode);
          })
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
  }

  private executeHousekeeperAction(action: HousekeeperAction): void {
    if (action.deviceType === 'light') {
      let lights = this.allLights();
      for (let i = 0; i < lights.length; i += 1) {
        let brightness = action.brightness !== undefined ? action.brightness : (action.power ? 72 : 0);
        this.syncDeviceBrightness(lights[i].device, brightness);
      }
      return;
    }
    if (action.deviceType === 'curtain') {
      let curtains = this.allCurtains();
      for (let i = 0; i < curtains.length; i += 1) {
        let openness = action.brightness !== undefined ? action.brightness : (action.power ? 60 : 0);
        this.syncDeviceBrightness(curtains[i].device, openness);
      }
      return;
    }
    if (action.deviceType === 'air') {
      let cards = this.allAirCards();
      for (let i = 0; i < cards.length; i += 1) {
        let device = cards[i].device;
        this.syncAirState(
          device,
          action.power === true,
          action.temperature !== undefined ? action.temperature : this.currentAirTemperature(device),
          action.mode ? action.mode : this.currentAirMode(device)
        );
      }
      return;
    }
    if (action.deviceType === 'door') {
      let door = this.firstDoorDevice();
      if (door && action.locked === true) {
        this.lockDoor(door);
      }
      return;
    }
    if (action.deviceType === 'speaker') {
      let speakers = this.allDeviceCardsByType('speaker');
      for (let i = 0; i < speakers.length; i += 1) {
        this.controlSpeakerMusic(speakers[i].device, action.power === true);
      }
      return;
    }
    if (action.deviceType === 'robot') {
      let robots = this.allDeviceCardsByType('robot');
      for (let i = 0; i < robots.length; i += 1) {
        this.controlRobot(robots[i].device, action.power === true);
      }
    }
  }

  private executeHousekeeperPlan(): void {
    if (!this.housekeeperPlan) {
      this.showDialog('请先生成调度方案');
      return;
    }
    this.housekeeperExecutionTitle = '';
    this.housekeeperExecutionLines = [];
    this.housekeeperExecuting = true;
    this.requestPost('/api/ai/execute', this.createHousekeeperExecutePayload(), (success: boolean, result: string) => {
      if (!success) {
        for (let i = 0; i < this.housekeeperPlan!.actions.length; i += 1) {
          this.executeHousekeeperAction(this.housekeeperPlan!.actions[i]);
        }
        let resultLines: string[] = [];
        for (let i = 0; i < this.housekeeperPlan!.actions.length; i += 1) {
          let action = this.housekeeperPlan!.actions[i];
          if (action.deviceType === 'light') {
            resultLines.push(`灯光：${action.power ? '已开启' : '已关闭'}${action.brightness !== undefined && action.power ? '，亮度 ' + action.brightness + '%' : ''}`);
          } else if (action.deviceType === 'curtain') {
            resultLines.push(`窗帘：${action.power ? '已开启' : '已关闭'}${action.brightness !== undefined ? '，开合度 ' + action.brightness + '%' : ''}`);
          } else if (action.deviceType === 'air') {
            resultLines.push(`空调：${action.power ? '已开启' : '已关闭'}${action.temperature !== undefined && action.power ? '，目标温度 ' + action.temperature + '℃' : ''}`);
          } else if (action.deviceType === 'door') {
            resultLines.push(`门禁：${action.locked ? '已上锁' : '保持当前状态'}`);
          } else if (action.deviceType === 'speaker') {
            resultLines.push(`音箱：${action.power ? '开始播放音乐' : '已暂停音乐'}`);
          } else if (action.deviceType === 'robot') {
            resultLines.push(`扫地机器人：${action.power ? '开始清扫' : '已停止清扫'}`);
          }
        }
        resultLines.push('状态已同步至数字孪生平台');
        this.housekeeperExecutionTitle = '已完成全屋协同调度';
        this.housekeeperExecutionLines = resultLines;
        this.housekeeperStatus = '调度已执行完成（当前为本地兜底执行）';
        this.housekeeperExecuting = false;
        this.loadStatus();
        this.markLocalDemoMode();
        return;
      }
      let response = this.parseHousekeeperExecuteResponse(result);
      if (!response.success) {
        this.housekeeperExecuting = false;
        this.showDialog(response.message ? response.message : 'AI 调度执行失败');
        return;
      }
      this.housekeeperExecutionTitle = response.executionTitle ? response.executionTitle : '已完成全屋协同调度';
      this.housekeeperExecutionLines = response.executionLines ? response.executionLines : [];
      this.housekeeperStatus = '调度已执行完成';
      this.housekeeperExecuting = false;
      this.loadStatus();
    });
  }

  @Builder
  AuthPage() {
    Column() {
      Column({ space: 22 }) {
        Column({ space: 10 }) {
          Text('鸿居智控')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .textAlign(TextAlign.Center)
            .width('100%')
          Text('智能家居设备控制系统')
            .fontSize(15)
            .fontColor('#7A8494')
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .width('100%')

        Column({ space: 16 }) {
          Text(this.isRegisterMode ? '注册账号' : '登录账号')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#18212F')
            .width('100%')

          TextInput({ placeholder: '请输入用户名', text: this.username })
            .height(50)
            .fontSize(16)
            .backgroundColor('#F4F6F9')
            .borderRadius(14)
            .padding({ left: 16, right: 16 })
            .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 3 })
            .onChange((value: string) => {
              this.username = value;
            })

          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .height(50)
            .fontSize(16)
            .backgroundColor('#F4F6F9')
            .borderRadius(14)
            .padding({ left: 16, right: 16 })
            .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 3 })
            .onChange((value: string) => {
              this.password = value;
            })

          if (this.isRegisterMode) {
            TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
              .type(InputType.Password)
              .height(50)
              .fontSize(16)
              .backgroundColor('#F4F6F9')
              .borderRadius(14)
              .padding({ left: 16, right: 16 })
              .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 3 })
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
          }

          Button(this.isRegisterMode ? '注册' : '登录')
            .height(50)
            .width('100%')
            .borderRadius(14)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .shadow({ radius: 12, color: '#1F7FAED6', offsetX: 3, offsetY: 5 })
            .onClick(() => {
              if (this.isRegisterMode) {
                this.register();
              } else {
                this.login();
              }
            })

          Row() {
            Text(this.isRegisterMode ? '返回登录' : '注册账号')
              .fontSize(13)
              .fontColor('#5C88AF')
              .onClick(() => {
                this.isRegisterMode = !this.isRegisterMode;
              })
            Blank()
            Text('忘记密码')
              .fontSize(13)
              .fontColor('#5C88AF')
              .onClick(() => {
                this.showDialog('演示版请联系管理员重置密码');
              })
          }
          .width('100%')
        }
        .padding({ left: 18, right: 18, top: 22, bottom: 22 })
        .backgroundColor('#F9FAFC')
        .borderRadius(18)
        .shadow({ radius: 18, color: '#12000000', offsetX: 4, offsetY: 6 })
        .width('100%')
      }
      .width('100%')
      .padding({ left: 26, right: 26 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2F6')
  }

  @Builder
  HeaderPanel() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 5 }) {
          Text(this.currentUser.length > 0 ? this.currentUser + '的家' : '我的家')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
          Text('当前用户：' + this.currentUser)
            .fontSize(11)
            .fontColor('#7A8494')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button() {
          Text('+')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#5C88AF')
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .width(48)
        .height(48)
        .padding(0)
        .borderRadius(16)
        .backgroundColor('#F9FAFC')
        .shadow({ radius: 12, color: '#12000000', offsetX: 3, offsetY: 5 })
        .onClick(() => {
          this.showAddMenuDialog = true;
        })
      }
      .width('100%')

      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('温度监测')
            .fontSize(12)
            .fontColor('#7A8494')
          Text(this.currentTemperatureText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
        }
        .alignItems(HorizontalAlign.Start)
        .padding(16)
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 10, color: '#10000000', offsetX: 2, offsetY: 4 })

        Column({ space: 6 }) {
          Text('湿度监测')
            .fontSize(12)
            .fontColor('#7A8494')
          Text(this.currentHumidityText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
        }
        .alignItems(HorizontalAlign.Start)
        .padding(16)
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 10, color: '#10000000', offsetX: 2, offsetY: 4 })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  SummaryCard(value: string, label: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
      Text(label)
        .fontSize(12)
        .fontColor('#7A8494')
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height(94)
    .layoutWeight(1)
    .backgroundColor('#F9FAFC')
    .borderRadius(18)
    .shadow({ radius: 12, color: '#12000000', offsetX: 3, offsetY: 5 })
  }

  @Builder
  SummaryPanel() {
    Column({ space: 6 }) {
      Text('当前模式')
        .fontSize(12)
        .fontColor('#7A8494')
      Text(this.currentMode === 'home' ? '回家模式' : '离家模式')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(18)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 10, color: '#10000000', offsetX: 2, offsetY: 4 })
    .width('100%')
  }

  @Builder
  ModeButton(title: string, active: boolean, color: string, clickAction: () => void) {
    Button(title)
      .height(52)
      .layoutWeight(1)
      .borderRadius(16)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .backgroundColor(active ? color : '#F9FAFC')
      .fontColor(active ? '#FFFFFF' : '#485D77')
      .shadow({ radius: 12, color: '#12000000', offsetX: 3, offsetY: 5 })
      .onClick(() => {
        clickAction();
      })
  }

  @Builder
  ModePanel() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        this.ModeButton('离家模式', this.currentMode === 'away', '#485D77', () => {
          this.applyAwayMode();
        })
        this.ModeButton('回家模式', this.currentMode === 'home', '#7FAED6', () => {
          this.applyHomeMode();
        })
      }
      .width('100%')

      Button('预设回家模式')
        .height(42)
        .width('100%')
        .borderRadius(14)
        .backgroundColor('#F9FAFC')
        .fontColor('#5C88AF')
        .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
        .onClick(() => {
          this.showSceneDialog = true;
        })
    }
    .width('100%')
  }

  @Builder
  TypeTab(item: TypeOption) {
    Column({ space: 7 }) {
      Text(item.icon)
        .fontSize(19)
        .fontColor(this.selectedType === item.key ? '#FFFFFF' : '#7A8494')
      Text(item.label)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedType === item.key ? '#FFFFFF' : '#485D77')
    }
    .justifyContent(FlexAlign.Center)
    .width(84)
    .height(76)
    .backgroundColor(this.selectedType === item.key ? '#7FAED6' : '#F9FAFC')
    .borderRadius(18)
    .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
    .onClick(() => {
      this.selectType(item.key);
    })
  }

  @Builder
  DeviceTypeTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.visibleTypeOptions(), (item: TypeOption) => {
          this.TypeTab(item);
        }, (item: TypeOption) => item.key)
      }
      .padding({ right: 4 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  BatchButton(label: string, power: boolean) {
    Button(label)
      .width(84)
      .height(92)
      .borderRadius(20)
      .backgroundColor('#2E3441')
      .fontColor('#FFFFFF')
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        this.controlAllType(power);
      })
  }

  @Builder
  RoomBadge(roomName: string) {
    Text(roomName)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedRoomFilter === roomName ? '#FFFFFF' : '#5C88AF')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.selectedRoomFilter === roomName ? '#7FAED6' : '#F9FAFC')
      .borderRadius(14)
      .shadow({ radius: 8, color: '#10000000', offsetX: 2, offsetY: 3 })
      .onClick(() => {
        this.selectedRoomFilter = roomName;
      })
  }

  @Builder
  DoorStatusTile(label: string, value: string, accent: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#8A93A3')
      Text(value)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .padding(16)
    .constraintSize({ minHeight: 88 })
    .layoutWeight(1)
    .backgroundColor('#F9FAFC')
    .borderRadius(18)
  }

  @Builder
  DoorActionButton(label: string, color: string, textColor: string, action: () => void) {
    Button(label)
      .height(46)
      .layoutWeight(1)
      .borderRadius(16)
      .backgroundColor(color)
      .fontColor(textColor)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        action();
      })
  }

  @Builder
  DoorPanel(card: DeviceCardInfo) {
    Column({ space: 16 }) {
      Text(this.hasCheckedDoorCamera(card.device) ?
        '\u95e8\u53e3\u753b\u9762\u5df2\u786e\u8ba4\uff0c\u53ef\u4ee5\u6267\u884c\u8fdc\u7a0b\u89e3\u9501' :
        '\u8bf7\u5148\u67e5\u770b\u95e8\u53e3\u753b\u9762\uff0c\u518d\u6267\u884c\u8fdc\u7a0b\u89e3\u9501')
        .fontSize(14)
        .fontColor('#1E2633')
        .lineHeight(21)
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

      Row({ space: 14 }) {
        this.DoorStatusTile('\u95e8\u9501\u72b6\u6001', this.doorLockText(card.device),
          card.device.locked === false ? '#2F80C4' : '#2F80C4')
        this.DoorStatusTile('\u95e8\u4f53\u72b6\u6001', this.doorBodyText(card.device),
          card.device.doorStatus === 'opened' ? '#2F80C4' : '#1E2633')
      }
      .width('100%')

      Row({ space: 14 }) {
        this.DoorActionButton('\u67e5\u770b\u6444\u50cf\u5934', '#FFFFFF', '#1E2633', () => {
          this.viewDoorCamera(card.device);
        })
        this.DoorActionButton('\u8fdc\u7a0b\u89e3\u9501',
          this.hasCheckedDoorCamera(card.device) ? '#2F80C4' : '#9AA1AB', '#FFFFFF', () => {
          this.unlockDoor(card.device);
        })
      }
      .width('100%')

      Row() {
        this.DoorActionButton('\u4e00\u952e\u4e0a\u9501', '#2E3441', '#FFFFFF', () => {
          this.lockDoor(card.device);
        })
      }
      .width('100%')
    }
    .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    .width('100%')
  }

  @Builder
  DeviceCard(card: DeviceCardInfo) {
    Column({ space: 10 }) {
      Row() {
        Text(this.roomIcon(card.roomName))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(30)
          .height(30)
          .textAlign(TextAlign.Center)
          .backgroundColor('#455062')
          .borderRadius(15)
        Blank()
        Row({ space: 8 }) {
          Text(this.typeLabel(this.normalizeType(card.device.type)))
            .fontSize(12)
            .fontColor('#B8C0CF')
          Button() {
            Text('x')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E6EDF7')
          }
          .width(24)
          .height(24)
          .padding(0)
          .borderRadius(12)
          .backgroundColor('#495567')
          .onClick(() => {
            this.confirmDeleteDevice(card);
          })
        }
      }
      .width('100%')

      Text(card.roomName)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')

      Text(card.device.name)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#DCE3EE')
        .width('100%')

      Text(this.deviceStatusText(card.device))
        .fontSize(12)
        .fontColor('#B8C0CF')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (this.normalizeType(card.device.type) === 'light' || this.normalizeType(card.device.type) === 'curtain') {
        Column({ space: 6 }) {
          Row() {
            Text(this.normalizeType(card.device.type) === 'curtain' ? '开合度' : '亮度')
              .fontSize(12)
              .fontColor('#B8C0CF')
            Blank()
            Text(this.currentDeviceBrightness(card.device).toString() + '%')
              .fontSize(12)
              .fontColor('#DCE3EE')
          }
          .width('100%')

          Slider({
            value: this.currentDeviceBrightness(card.device),
            min: 0,
            max: 100,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .selectedColor('#F4C84A')
            .trackColor('#566173')
            .blockColor('#FFFFFF')
            .showSteps(false)
            .onChange((value: number) => {
              this.updateDeviceBrightness(card.device, value);
            })
            .onTouch((event?: TouchEvent) => {
              if (event && event.type === TouchType.Up) {
                this.syncDeviceBrightnessById(card.device.id);
              }
            })
        }
        .width('100%')
      }

      if (this.normalizeType(card.device.type) === 'speaker') {
        Column({ space: 8 }) {
          Text(card.device.musicPlaying ? '网页端播放中' : (card.device.musicTitle || '智能音箱演示音乐'))
            .fontSize(12)
            .fontColor('#DCE3EE')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Button('播报状态')
            .height(34)
            .width('100%')
            .borderRadius(12)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.broadcastWithSpeaker(card.device, '查询全屋状态', '门禁已上锁，安全传感器正常');
            })

          Button(card.device.musicPlaying ? '暂停播放' : '自动播放')
            .height(34)
            .width('100%')
            .borderRadius(12)
            .backgroundColor(card.device.musicPlaying ? '#6D7482' : '#12B4A7')
            .fontColor('#FFFFFF')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.controlSpeakerMusic(card.device, !(card.device.musicPlaying === true));
            })
        }
        .width('100%')
      }

      if (this.normalizeType(card.device.type) === 'robot') {
        Column({ space: 8 }) {
          Row() {
            Text('进度')
              .fontSize(12)
              .fontColor('#B8C0CF')
            Blank()
            Text((card.device.cleaningProgress !== undefined ? card.device.cleaningProgress : 0).toString() + '%')
              .fontSize(12)
              .fontColor('#DCE3EE')
          }
          .width('100%')
          Button(card.device.power ? '自动清扫中' : '开启自动清扫')
            .height(34)
            .width('100%')
            .borderRadius(12)
            .backgroundColor(card.device.power ? '#12B4A7' : '#566173')
            .fontColor('#FFFFFF')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.controlRobot(card.device, true);
            })
          Button('停止')
            .height(34)
            .width('100%')
            .borderRadius(12)
            .backgroundColor('#6D7482')
            .fontColor('#FFFFFF')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.controlRobot(card.device, false);
            })
        }
        .width('100%')
      }

      Blank()

      if (this.normalizeType(card.device.type) !== 'robot') {
        Button(this.deviceActive(card.device) ? '关闭' : '开启')
          .width('100%')
          .height(44)
          .borderRadius(15)
          .backgroundColor(this.deviceActive(card.device) ? '#12B4A7' : '#6D7482')
          .fontColor('#FFFFFF')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.controlDevice(card.device, !this.deviceActive(card.device));
          })
      }
    }
    .padding(16)
    .width(164)
    .height(this.normalizeType(card.device.type) === 'light' ? 270 :
      (this.normalizeType(card.device.type) === 'curtain' ? 270 :
        (this.normalizeType(card.device.type) === 'robot' ? 300 :
          (this.normalizeType(card.device.type) === 'speaker' ? 250 : 210))))
    .backgroundColor('#2E3441')
    .borderRadius(22)
  }

  @Builder
  EmptyTypeCard() {
    Column({ space: 10 }) {
      Text('还没有此类设备')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#485D77')
      Text('点击右上角加号，填写房间名称和设备名称后即可自动归类')
        .fontSize(12)
        .fontColor('#7A8494')
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .width('100%')
    .backgroundColor('#F9FAFC')
    .borderRadius(18)
    .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
  }

  @Builder
  StableEmptyTypePanel() {
    Column() {
      this.EmptyTypeCard()
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .constraintSize({ minHeight: 320 })
  }

  @Builder
  EmptyAddDeviceCard() {
    Column({ space: 18 }) {
      Column() {
        Text('发现附近新设备')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('100%')
      }
      .width('100%')

      Column({ space: 20 }) {
        Column()
          .width('100%')
          .height(170)
          .backgroundColor('#F8FAFE')
          .borderRadius(28)

        Button('添加设备')
          .width('100%')
          .height(56)
          .borderRadius(20)
          .backgroundColor('#20C997')
          .fontColor('#FFFFFF')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.showAddDeviceDialog = true;
          })
      }
      .padding(20)
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(30)
      .shadow({ radius: 16, color: '#18000000', offsetX: 4, offsetY: 8 })
    }
    .padding({ left: 18, right: 18, top: 22, bottom: 22 })
    .width('100%')
    .backgroundColor('#8BC5F5')
    .borderRadius(30)
  }

  @Builder
  EmptyLearnCard() {
    Column({ space: 16 }) {
      Text('新用户推荐')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')

      Row() {
        Column({ space: 8 }) {
          Text('了解鸿居')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text('智能家居设备控制系统')
            .fontSize(14)
            .fontColor('#7A8494')
            .width('100%')
          Blank()
          Button('立即了解')
            .width(112)
            .height(42)
            .borderRadius(16)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.showLearnHongju();
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 10 }) {
          Text('卧')
            .fontSize(44)
            .fontWeight(FontWeight.Bold)
            .fontColor('#7FAED6')
            .width(88)
            .height(88)
            .textAlign(TextAlign.Center)
            .backgroundColor('#EEF4FB')
            .borderRadius(44)
          Text('家')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#A0A9B8')
        }
        .width(100)
      }
      .padding(22)
      .width('100%')
      .height(220)
      .backgroundColor('#FFFFFF')
      .borderRadius(30)
      .shadow({ radius: 16, color: '#18000000', offsetX: 4, offsetY: 8 })
    }
    .padding({ left: 18, right: 18, top: 22, bottom: 22 })
    .width('100%')
    .backgroundColor('#9FD4FA')
    .borderRadius(30)
  }

  @Builder
  EmptyHomePanel() {
    Column({ space: 18 }) {
      this.EmptyAddDeviceCard()
      this.EmptyLearnCard()
    }
    .width('100%')
  }

  @Builder
  AirModeChip(mode: string, activeMode: string) {
    Text(mode)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.isAirModeActive(activeMode, mode) ? '#165C4E' : '#DCE3EE')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.isAirModeActive(activeMode, mode) ? '#DFF4EB' : '#364051')
      .borderRadius(18)
      .onClick(() => {
        this.changeAirMode(mode);
      })
  }

  @Builder
  SceneAirModeChip(mode: string, activeMode: string) {
    Text(mode)
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.isAirModeActive(activeMode, mode) ? '#FFFFFF' : '#485D77')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.isAirModeActive(activeMode, mode) ? '#7FAED6' : '#EEF2F6')
      .borderRadius(18)
      .onClick(() => {
        let cards = this.allAirCards();
        if (cards.length > 0) {
          this.updateSceneAirMode(this.selectedSceneMode, cards[0].device.id, mode);
        }
      })
  }

  @Builder
  AirAdjustButton(label: string, action: () => void) {
    Button(label)
      .width(54)
      .height(54)
      .borderRadius(16)
      .backgroundColor('#364051')
      .fontColor('#FFFFFF')
      .fontSize(26)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        action();
      })
  }

  @Builder
  AirControlPanel() {
    if (!this.hasAirDevices()) {
      this.EmptyTypeCard()
    } else {
      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.currentAirRoomName() + '空调控制中心')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            Text('温度与模式会实时同步到当前房间场景')
              .fontSize(13)
              .fontColor('#AEB8C8')
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.currentAirDevice()!.power ? '空调运行中' : '空调已关闭')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentAirDevice()!.power ? '#165C4E' : '#DCE3EE')
            .padding({ left: 18, right: 18, top: 12, bottom: 12 })
            .backgroundColor(this.currentAirDevice()!.power ? '#DFF4EB' : '#364051')
            .borderRadius(20)
        }
        .width('100%')

        Row() {
          Button(this.currentAirDevice()!.power ? '关闭空调' : '开启空调')
            .height(46)
            .padding({ left: 22, right: 22 })
            .borderRadius(23)
            .backgroundColor('#DFF4EB')
            .fontColor('#165C4E')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.syncAirState(
                this.currentAirDevice()!,
                !this.currentAirDevice()!.power,
                this.currentAirTemperature(this.currentAirDevice()!),
                this.currentAirMode(this.currentAirDevice()!)
              );
            })
          Blank()
          Text('模式 ' + this.currentAirModeText)
            .fontSize(14)
            .fontColor('#AEB8C8')
        }
        .width('100%')

        Row({ space: 14 }) {
          this.AirAdjustButton('-', () => {
            this.changeAirTemperature(-1);
          })
          Column({ space: 8 }) {
            Text('设定温度')
              .fontSize(13)
              .fontColor('#C9D3E1')
            Text(this.currentAirTemperature(this.currentAirDevice()!).toString() + '℃')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
          .height(102)
          .backgroundColor('#364051')
          .borderRadius(22)

          this.AirAdjustButton('+', () => {
            this.changeAirTemperature(1);
          })
        }
        .width('100%')

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.airModes, (mode: string) => {
              this.AirModeChip(mode, this.currentAirModeText);
            }, (mode: string) => mode + '_' + this.currentAirModeText)
          }
          .padding({ right: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

      }
      .padding(18)
      .width('100%')
      .backgroundColor('#1F2633')
      .borderRadius(24)
    }
  }

  @Builder
  TypeControlPanel() {
    Column({ space: 14 }) {
      Row() {
        Text(this.typeLabel(this.selectedType))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')
          .layoutWeight(1)
        Text(this.updatedAt.length >= 19 ? this.updatedAt.substring(11, 19) : '--')
          .fontSize(12)
          .fontColor('#7A8494')
      }
      .width('100%')

      if (this.selectedType !== 'door' && this.deviceCardsForSelectedType().length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.roomFilterNamesForSelectedType(), (roomName: string) => {
              this.RoomBadge(roomName);
            }, (roomName: string) => roomName)
          }
          .padding({ right: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      if (this.deviceCardsForSelectedType().length > 0 && this.selectedType === 'door') {
        Column({ space: 14 }) {
          ForEach(this.deviceCardsForSelectedType(), (card: DeviceCardInfo) => {
            this.DoorPanel(card);
          }, (card: DeviceCardInfo) => this.deviceRenderKey(card))
        }
        .width('100%')
      } else if (this.deviceCardsForSelectedType().length > 0 && this.selectedType === 'air') {
        this.AirControlPanel()
      } else if (this.deviceCardsForSelectedType().length > 0) {
        Scroll() {
          Row({ space: 14 }) {
            ForEach(this.filteredDeviceCardsForSelectedType(), (card: DeviceCardInfo) => {
              this.DeviceCard(card);
            }, (card: DeviceCardInfo) => this.deviceRenderKey(card))
            Column({ space: 12 }) {
              this.BatchButton('全开', true)
              this.BatchButton('全关', false)
            }
          }
          .padding({ right: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

      } else {
        this.StableEmptyTypePanel()
      }
    }
    .padding(18)
    .backgroundColor('#EEF2F6')
    .borderRadius(22)
    .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
    .width('100%')
    .constraintSize({ minHeight: 430 })
  }

  @Builder
  LogPanel() {
    Column({ space: 10 }) {
      Row() {
        Text('鎿嶄綔鏃ュ織')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')
        Blank()
        Text(this.syncMessage)
          .fontSize(11)
          .fontColor('#7A8494')
      }
      .width('100%')

      if (this.logs.length === 0) {
        Text('鏆傛棤鎿嶄綔璁板綍')
          .fontSize(12)
          .fontColor('#7A8494')
          .padding({ left: 12, right: 12, top: 12, bottom: 12 })
          .width('100%')
          .backgroundColor('#F9FAFC')
          .borderRadius(14)
      } else {
        ForEach(this.logs.slice(0, 5), (item: LogInfo) => {
          Text((item.time.length >= 19 ? item.time.substring(11, 19) : '--:--:--') + '  ' + item.detail)
            .fontSize(12)
            .fontColor('#485D77')
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .backgroundColor('#F9FAFC')
            .borderRadius(14)
            .shadow({ radius: 8, color: '#10000000', offsetX: 2, offsetY: 3 })
            .width('100%')
        }, (item: LogInfo) => item.id.toString())
      }
    }
    .width('100%')
  }

  @Builder
  HomePage() {
    Scroll() {
      Column({ space: 18 }) {
        this.HeaderPanel()
        if (this.isEmptyHome()) {
          this.EmptyHomePanel()
        } else {
          this.SummaryPanel()
          this.ModePanel()
          this.DeviceTypeTabs()
          this.TypeControlPanel()
        }
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 28 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabSummaryCard(value: string, label: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
      Text(label)
        .fontSize(12)
        .fontColor('#7A8494')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .layoutWeight(1)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
  }

  @Builder
  HousekeeperStatusChip(label: string, value: string, accent: boolean = false) {
    Row({ space: 8 }) {
      Text(label)
        .fontSize(12)
        .fontColor('#7A8494')
      Text(value)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent ? '#5C88AF' : '#1E2633')
    }
    .padding({ left: 12, right: 12, top: 9, bottom: 9 })
    .margin({ right: 10, bottom: 10 })
    .backgroundColor(accent ? '#EAF2FB' : '#F4F6F9')
    .borderRadius(14)
  }

  @Builder
  SceneSelectionCard() {
    Column({ space: 8 }) {
      Text(this.sceneModeLabel(this.selectedSceneMode))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
        .width('100%')
      Text(this.sceneModeDetail(this.selectedSceneMode))
        .fontSize(12)
        .fontColor('#7A8494')
        .width('100%')
      Text('当前选择')
        .fontSize(12)
        .fontColor('#7A8494')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .layoutWeight(1)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
  }

  @Builder
  ButlerSuggestion(title: string, detail: string, action: () => void) {
    Button() {
      Column({ space: 8 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')
          .width('100%')
        Text(detail)
          .fontSize(12)
          .fontColor('#7A8494')
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
    .onClick(() => {
      action();
    })
  }

  @Builder
  ProfileActionRow(title: string, detail: string, action: () => void) {
    Button() {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text(detail)
            .fontSize(12)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text('>')
          .fontSize(18)
          .fontColor('#A0A9B8')
      }
      .width('100%')
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
    .onClick(() => {
      action();
    })
  }

  @Builder
  UtilityTypeChip(type: string) {
    Text(this.utilityLabel(type))
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.selectedUtilityType === type ? '#FFFFFF' : '#485D77')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.selectedUtilityType === type ? '#7FAED6' : '#F4F6F9')
      .borderRadius(14)
      .onClick(() => {
        this.selectedUtilityType = type;
      })
  }

  @Builder
  SceneQuickButton(title: string, active: boolean, color: string, action: () => void) {
    Button(title)
      .height(52)
      .layoutWeight(1)
      .borderRadius(18)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .backgroundColor(active ? color : '#FFFFFF')
      .fontColor(active ? '#FFFFFF' : '#485D77')
      .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
      .onClick(() => {
        action();
      })
  }

  @Builder
  SceneModeButton(title: string, mode: string, color: string) {
    Button(title)
      .height(52)
      .padding({ left: 18, right: 18 })
      .borderRadius(18)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .backgroundColor(this.selectedSceneMode === mode ? '#7FAED6' : '#FFFFFF')
      .fontColor(this.selectedSceneMode === mode ? '#FFFFFF' : '#485D77')
      .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
      .onClick(() => {
        this.selectedSceneMode = mode;
        this.runSceneMode(mode);
      })
  }

  @Builder
  AddSceneModeButton() {
    Button('+ 添加场景模式')
      .height(40)
      .padding({ left: 16, right: 16 })
      .borderRadius(14)
      .backgroundColor('#F4F7FB')
      .fontColor('#5C88AF')
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .onClick(() => {
        this.showAddSceneModeDialog = true;
      })
  }

  @Builder
  SceneDeviceEditorCard(mode: string, card: DeviceCardInfo) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(card.device.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text(card.roomName + ' · ' + this.typeLabel(this.normalizeType(card.device.type)))
            .fontSize(12)
            .fontColor('#7A8494')
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Row() {
          this.ScenePresetToggle(this.sceneDeviceEnabled(mode, card.device.id), () => {
            this.updateSceneDeviceEnabled(mode, card.device.id, true);
          }, () => {
            this.updateSceneDeviceEnabled(mode, card.device.id, false);
          })
        }
      }
      .width('100%')

      if (this.normalizeType(card.device.type) === 'light' || this.normalizeType(card.device.type) === 'curtain') {
        Row() {
          Text(this.normalizeType(card.device.type) === 'curtain' ? '开合度' : '亮度')
            .fontSize(12)
            .fontColor('#7A8494')
          Blank()
          Text(this.sceneLightBrightness(mode, card.device.id).toString() + '%')
            .fontSize(12)
            .fontColor('#485D77')
        }
        .width('100%')
        Slider({
          value: this.sceneLightBrightness(mode, card.device.id),
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .selectedColor('#7FAED6')
          .trackColor('#D8E1EC')
          .blockColor('#FFFFFF')
          .showSteps(false)
          .enabled(this.sceneDeviceEnabled(mode, card.device.id))
          .onChange((value: number) => {
            this.updateSceneLightBrightness(mode, card.device.id, value);
          })
        if (this.normalizeType(card.device.type) === 'curtain') {
          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.curtainModes, (itemMode: string) => {
                Text(itemMode)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.sceneAirModeText(mode, card.device.id) === itemMode ? '#FFFFFF' : '#485D77')
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .backgroundColor(this.sceneAirModeText(mode, card.device.id) === itemMode ? '#7FAED6' : '#EEF2F6')
                  .borderRadius(18)
                  .onClick(() => {
                    this.updateSceneAirMode(mode, card.device.id, itemMode);
                  })
              }, (itemMode: string) => itemMode)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
      } else if (this.normalizeType(card.device.type) === 'air') {
        Row({ space: 14 }) {
          this.AirAdjustButton('-', () => {
            this.updateSceneAirTemperature(mode, card.device.id, -1);
          })
          Column({ space: 6 }) {
            Text('目标温度')
              .fontSize(12)
              .fontColor('#7A8494')
            Text(this.sceneAirTemperature(mode, card.device.id).toString() + '°C')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E2633')
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
          .height(88)
          .backgroundColor('#F4F6F9')
          .borderRadius(18)
          this.AirAdjustButton('+', () => {
            this.updateSceneAirTemperature(mode, card.device.id, 1);
          })
        }
        .width('100%')
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.airModes, (itemMode: string) => {
              Text(itemMode)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isAirModeActive(this.sceneAirModeText(mode, card.device.id), itemMode) ? '#FFFFFF' : '#485D77')
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .backgroundColor(this.isAirModeActive(this.sceneAirModeText(mode, card.device.id), itemMode) ? '#7FAED6' : '#EEF2F6')
                .borderRadius(18)
                .onClick(() => {
                  this.updateSceneAirMode(mode, card.device.id, itemMode);
                })
            }, (itemMode: string) => itemMode)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      } else if (this.normalizeType(card.device.type) === 'door') {
        Text('安全规则：场景模式仅支持保持上锁，不提供自动解锁。')
          .fontSize(12)
          .fontColor('#7A8494')
          .width('100%')
      }
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }

  @Builder
  HomeTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        this.HeaderPanel()
        if (this.isEmptyHome()) {
          this.EmptyHomePanel()
        } else {
          this.DeviceTypeTabs()
          this.TypeControlPanel()
        }
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SceneTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text('场景')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text('固定场景一键切换设备状态')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 12 }) {
          Row({ space: 12 }) {
            this.SceneQuickButton('回家', this.currentMode === 'home', '#7FAED6', () => {
              this.applyHomeMode();
            })
            this.SceneQuickButton('离家', this.currentMode === 'away', '#485D77', () => {
              this.applyAwayMode();
            })
          }
          .width('100%')

          Row({ space: 12 }) {
            this.SceneQuickButton('睡眠', false, '#6C7A92', () => {
              this.selectType('light');
              this.controlAllType(false);
              this.selectType('air');
              this.controlAllType(true);
              this.showDialog('睡眠场景已执行');
            })
            this.SceneQuickButton('节能', false, '#33A37A', () => {
              this.selectType('light');
              this.controlAllType(false);
              this.selectType('air');
              this.controlAllType(false);
              this.showDialog('节能场景已执行');
            })
          }
          .width('100%')
        }
        .width('100%')

        Button('编辑场景预设')
          .height(46)
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#F9FAFC')
          .fontColor('#5C88AF')
          .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
          .onClick(() => {
            this.showSceneDialog = true;
          })

          Row({ space: 12 }) {
          this.TabSummaryCard(this.sceneConfiguredCount('home').toString(), '已配置回家设备')
          this.TabSummaryCard(this.currentMode === 'home' ? '回家中' : '离家中', '当前状态')
        }
        .width('100%')
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ButlerTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text('绠″')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text('AI 助手与多设备协同建议')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 12 }) {
          this.ButlerSuggestion('晚上帮我看门', '联动门禁与摄像头，优先提醒高风险访客', () => {
            this.showDialog('已为你准备夜间门禁守护方案');
          })
          this.ButlerSuggestion('回家前提前开空调', '根据当前模式和空调设备，建议一键切换回家场景', () => {
            this.applyHomeMode();
          })
          this.ButlerSuggestion('检查异常设备', '快速查看离线风险、失败记录和最近操作', () => {
            this.selectedBottomTab = 'home';
            this.selectType('door');
          })
        }
        .width('100%')

        Row({ space: 12 }) {
          this.TabSummaryCard(this.onlineSecurityCount().toString(), '已接入门禁')
          this.TabSummaryCard(this.averageTemperatureText(), '平均空调设温')
        }
        .width('100%')
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HousekeeperTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text('管家')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text('AI 家居管家，一句话调度全屋设备')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Column({ space: 4 }) {
              Text('家庭速览')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E2633')
              Text('管家会结合当前状态生成更合适的联动方案')
                .fontSize(12)
                .fontColor('#7A8494')
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text(this.currentMode === 'home' ? '回家中' : '离家中')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5C88AF')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#EAF2FB')
              .borderRadius(14)
          }
          .width('100%')

          Row({ space: 10 }) {
            this.HousekeeperStatusChip('温度', this.currentTemperatureText)
            this.HousekeeperStatusChip('湿度', this.currentHumidityText)
          }
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            this.HousekeeperStatusChip('灯光', this.allLights().some((card: DeviceCardInfo) => card.device.power) ? '开启中' : '已关闭',
              this.allLights().some((card: DeviceCardInfo) => card.device.power))
            this.HousekeeperStatusChip('窗帘',
              this.allCurtains().some((card: DeviceCardInfo) => (card.device.brightness !== undefined ? card.device.brightness : 0) > 0) ? '已开启' : '已关闭',
              this.allCurtains().some((card: DeviceCardInfo) => (card.device.brightness !== undefined ? card.device.brightness : 0) > 0))
            this.HousekeeperStatusChip('空调', this.allAirCards().some((card: DeviceCardInfo) => card.device.power) ? '开启中' : '已关闭',
              this.allAirCards().some((card: DeviceCardInfo) => card.device.power))
            this.HousekeeperStatusChip('门禁',
              this.firstDoorDevice() && this.firstDoorDevice()!.locked === false ? '未上锁' : '已上锁',
              !!(this.firstDoorDevice() && this.firstDoorDevice()!.locked !== false))
          }
          .width('100%')
        }
        .padding(14)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

        Column({ space: 12 }) {
          Row() {
            Text('请输入您的需求')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E2633')
            Blank()
            Button(this.voiceListening ? '识别中' : '语音输入')
              .height(34)
              .padding({ left: 14, right: 14 })
              .borderRadius(14)
              .backgroundColor(this.voiceListening ? '#EEF2F6' : '#EAF2FB')
              .fontColor('#5C88AF')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                this.simulateVoiceInput();
              })
          }
          .width('100%')

          TextInput({ placeholder: '请输入您的需求，例如：回家前把主卧调到舒适模式', text: this.housekeeperInput })
            .height(108)
            .fontSize(15)
            .backgroundColor('#F4F6F9')
            .borderRadius(16)
            .padding({ left: 14, right: 14, top: 12, bottom: 12 })
            .type(InputType.Normal)
            .onChange((value: string) => {
              this.housekeeperInput = value;
            })

          Button('生成调度方案')
            .height(46)
            .width('100%')
            .borderRadius(16)
            .backgroundColor('#1E2633')
            .fontColor('#FFFFFF')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.generateHousekeeperPlan();
            })

          Text('快捷指令')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')

          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.housekeeperPresetOptions(), (option: HousekeeperPresetOption) => {
                Text(option.label)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.housekeeperSelectedPreset === option.key ? '#FFFFFF' : '#5C88AF')
                  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
                  .backgroundColor(this.housekeeperSelectedPreset === option.key ? '#7FAED6' : '#F9FAFC')
                  .borderRadius(16)
                  .onClick(() => {
                    this.useHousekeeperPreset(option);
                  })
              }, (option: HousekeeperPresetOption) => option.key)
            }
            .padding({ right: 4 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

        Column({ space: 12 }) {
          Text('AI 调度方案')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')

          Text(this.housekeeperPlan ? this.housekeeperPlan.summary : this.housekeeperStatus)
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')

          if (this.housekeeperPlan) {
            Column({ space: 12 }) {
              Text('已识别意图：' + this.housekeeperPlan.intentLabel)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2E4E6D')
                .width('100%')

              ForEach(this.housekeeperPlan.actions, (action: HousekeeperAction, index: number) => {
                Column({ space: 6 }) {
                  Text((index + 1).toString() + '. ' + action.title + '：' + action.detail)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1E2633')
                    .width('100%')
                  Text('原因：' + action.reason)
                    .fontSize(12)
                    .fontColor('#7A8494')
                    .width('100%')
                }
                .padding(14)
                .width('100%')
                .backgroundColor('#F9FAFC')
                .borderRadius(14)
              }, (action: HousekeeperAction) => action.key)

              Row({ space: 12 }) {
                Button(this.housekeeperExecuting ? '执行中...' : '一键执行')
                  .height(46)
                  .layoutWeight(1)
                  .borderRadius(16)
                  .backgroundColor('#1E2633')
                  .fontColor('#FFFFFF')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .enabled(!this.housekeeperExecuting)
                  .onClick(() => {
                    this.executeHousekeeperPlan();
                  })
                Button('重新生成')
                  .height(46)
                  .layoutWeight(1)
                  .borderRadius(16)
                  .backgroundColor('#EAF2FB')
                  .fontColor('#2E4E6D')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .onClick(() => {
                    this.rerunHousekeeperPlan();
                  })
              }
              .width('100%')
            }
            .width('100%')
          } else {
            Text('先描述一个场景需求，管家会给出可执行的多设备联动方案。')
              .fontSize(12)
              .fontColor('#7A8494')
              .width('100%')
          }
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

        if (this.housekeeperExecutionLines.length > 0) {
          Column({ space: 8 }) {
            Text(this.housekeeperExecutionTitle)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E2633')
              .width('100%')
            ForEach(this.housekeeperExecutionLines, (line: string) => {
              Text(line)
                .fontSize(13)
                .fontColor('#485D77')
                .width('100%')
            }, (line: string) => line)
          }
          .padding(16)
          .width('100%')
          .backgroundColor('#F3FAF6')
          .borderRadius(18)
          .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })
        }
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SmartSceneTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('场景')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E2633')
              .width('100%')
            Text('一键切换或自定义家庭联动模式')
              .fontSize(12)
              .fontColor('#7A8494')
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          this.AddSceneModeButton()
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('当前模式：' + this.sceneModeLabel(this.selectedSceneMode))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text(this.sceneCurrentModeSummary(this.selectedSceneMode))
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')

          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.allSceneModes(), (item: SceneModePreset) => {
                this.SceneModeButton(item.label, item.key, this.sceneModeAccent(item.key))
              }, (item: SceneModePreset) => item.key)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

        Button('编辑场景预设')
          .height(46)
          .width('100%')
          .borderRadius(16)
          .backgroundColor('#F9FAFC')
          .fontColor('#5C88AF')
          .shadow({ radius: 10, color: '#12000000', offsetX: 2, offsetY: 4 })
          .onClick(() => {
            this.showSceneDialog = true;
          })

        Column({ space: 10 }) {
          Text('场景联动详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text(this.sceneModeLabel(this.selectedSceneMode) + ' 联动内容')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.sceneModeAccent(this.selectedSceneMode))
            .width('100%')
          Column({ space: 8 }) {
            ForEach(this.sceneModeActions(this.selectedSceneMode), (item: string) => {
              Text(item)
                .fontSize(14)
                .fontColor('#485D77')
                .width('100%')
            }, (item: string) => item)
          }
          .width('100%')
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({ radius: 8, color: '#10000000', offsetX: 1, offsetY: 3 })

      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ProfileTabPage() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 10 }) {
          Text('我的')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
          Text('生活缴费与家庭设备协同管理')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Row({ space: 12 }) {
          this.TabSummaryCard(this.totalRoomCount().toString(), '房间数量')
          this.TabSummaryCard(this.totalDeviceCount().toString(), '设备总数')
        }
        .width('100%')

        Column({ space: 12 }) {
          Text('生活缴费')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')

          Row({ space: 10 }) {
            this.TabSummaryCard(this.utilityAccount.electricBalance.toFixed(2) + ' 元', '电费余额')
            this.TabSummaryCard(this.utilityAccount.gasBalance.toFixed(2) + ' 元', '燃气余额')
          }
          .width('100%')

          Row({ space: 10 }) {
            this.TabSummaryCard(this.utilityAccount.waterBalance.toFixed(2) + ' 元', '水费余额')
            this.TabSummaryCard(this.familyMembers.length.toString() + ' 人', '家庭成员')
          }
          .width('100%')
        }
        .width('100%')

        Column({ space: 12 }) {
          this.ProfileActionRow('用户信息', '当前账号：' + this.currentUser, () => {
            this.showDialog('当前登录账号：' + this.currentUser);
          })
          this.ProfileActionRow('生活缴费', '电费、燃气费、水费统一充值', () => {
            this.showUtilityDialog = true;
          })
          this.ProfileActionRow('家庭管理', '按手机号添加家人，共享设备控制权限', () => {
            this.showFamilyDialog = true;
          })
          this.ProfileActionRow('退出登录', '退出当前鸿居账号', () => {
            this.logout();
          })
        }
        .width('100%')
      }
      .padding({ left: 20, right: 20, top: 18, bottom: 84 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BottomTabItem(item: BottomTabOption) {
    Column({ space: 6 }) {
      Text(item.icon)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedBottomTab === item.key ? '#5C88AF' : '#9BA6B6')
        .width(34)
        .height(34)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.selectedBottomTab === item.key ? '#EAF2FB' : '#00000000')
        .borderRadius(17)
      Text(item.label)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedBottomTab === item.key ? '#2E4E6D' : '#9BA6B6')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .height(62)
    .onClick(() => {
      this.selectedBottomTab = item.key;
    })
  }

  @Builder
  BottomTabBar() {
    Row() {
      ForEach(this.bottomTabOptions(), (item: BottomTabOption) => {
        this.BottomTabItem(item);
      }, (item: BottomTabOption) => item.key)
    }
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .width('100%')
    .backgroundColor('#F9FAFC')
    .borderRadius(0)
    .border({ width: { top: 1 }, color: '#E3EAF2' })
  }

  @Builder
  MainTabPage() {
    Column() {
      Column() {
        if (this.selectedBottomTab === 'home') {
          this.HomeTabPage()
        } else if (this.selectedBottomTab === 'scene') {
          this.SmartSceneTabPage()
        } else if (this.selectedBottomTab === 'butler') {
          this.HousekeeperTabPage()
        } else {
          this.ProfileTabPage()
        }
      }
      .layoutWeight(1)
      .width('100%')

      Column() {
        this.BottomTabBar()
      }
      .width('100%')
      .backgroundColor('#EEF2F6')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainTabPageOld() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.selectedBottomTab === 'home') {
        this.HomeTabPage()
      } else if (this.selectedBottomTab === 'scene') {
        this.SmartSceneTabPage()
      } else if (this.selectedBottomTab === 'butler') {
        this.HousekeeperTabPage()
      } else {
        this.ProfileTabPage()
      }

      Column() {
        this.BottomTabBar()
      }
      .width('100%')
      .backgroundColor('#EEF2F6')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuDialog() {
    Column() {
      Column({ space: 14 }) {
        Text('添加')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')
        Button('扫一扫')
          .height(46)
          .width('100%')
          .borderRadius(14)
          .backgroundColor('#F4F6F9')
          .fontColor('#485D77')
          .onClick(() => {
            this.showAddMenuDialog = false;
            this.showDialog('演示版暂未接入扫一扫');
          })
        Button('添加设备')
          .height(46)
          .width('100%')
          .borderRadius(14)
          .backgroundColor('#7FAED6')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.showAddMenuDialog = false;
            this.showAddDeviceDialog = true;
          })
        Button('取消')
          .height(42)
          .width('100%')
          .borderRadius(14)
          .backgroundColor('#EEF2F6')
          .fontColor('#7A8494')
          .onClick(() => {
            this.showAddMenuDialog = false;
          })
      }
      .padding(20)
      .width('82%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  DeviceTypeChip(type: string) {
    Text(this.typeLabel(type))
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.modalDeviceType === type ? '#FFFFFF' : '#485D77')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.modalDeviceType === type ? '#7FAED6' : '#F4F6F9')
      .borderRadius(14)
      .onClick(() => {
        this.modalDeviceType = type;
      })
  }

  @Builder
  AddDeviceDialog() {
    Column() {
      Column({ space: 16 }) {
        Text('添加设备')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')

        TextInput({ placeholder: '设备名称，例如主卧灯光', text: this.modalDeviceName })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.modalDeviceName = value;
          })

        TextInput({ placeholder: '房间名称，例如主卧、次卧、客厅', text: this.modalRoomName })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.modalRoomName = value;
          })

        Text('Preview 预览器里中文输入法可能无法正常上屏，模拟器或真机可正常测试中文。')
          .fontSize(11)
          .fontColor('#8A93A3')
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
          this.DeviceTypeChip('light')
          this.DeviceTypeChip('curtain')
          this.DeviceTypeChip('air')
          this.DeviceTypeChip('door')
          this.DeviceTypeChip('speaker')
          this.DeviceTypeChip('robot')
        }
        .width('100%')

        Row({ space: 10 }) {
          Button('取消')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#EEF2F6')
            .fontColor('#7A8494')
            .onClick(() => {
              this.showAddDeviceDialog = false;
              this.resetAddDeviceDialog();
            })

          Button('确认添加')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.addDevice();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  ScenePresetToggle(enabled: boolean, onEnable: () => void, onDisable: () => void) {
    Row({ space: 6 }) {
      Button('已关闭')
        .height(38)
        .padding({ left: 14, right: 14 })
        .borderRadius(12)
        .backgroundColor(!enabled ? '#4E8FDF' : '#F4F6F9')
        .fontColor(!enabled ? '#FFFFFF' : '#7A8494')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          onDisable();
        })

      Button('已启用')
        .height(38)
        .padding({ left: 14, right: 14 })
        .borderRadius(12)
        .backgroundColor(enabled ? '#4E8FDF' : '#F4F6F9')
        .fontColor(enabled ? '#FFFFFF' : '#7A8494')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          onEnable();
        })
    }
    .padding(4)
    .backgroundColor('#EEF2F6')
    .borderRadius(16)
    .border({ width: 1, color: '#E0E8F2' })
  }

  @Builder
  ScenePresetSection(title: string) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2633')
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  SceneDialog() {
    Column() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text(this.sceneModeLabel(this.selectedSceneMode) + '预设')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
          Text('设置进入' + this.sceneModeLabel(this.selectedSceneMode) + '时各设备的目标状态')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.allSceneDeviceCards(), (card: DeviceCardInfo) => {
              this.SceneDeviceEditorCard(this.selectedSceneMode, card)
            }, (card: DeviceCardInfo) => this.sceneDeviceRenderKey(this.selectedSceneMode, card.device.id))
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .width('100%')
        .constraintSize({ maxHeight: '62%' })

        Row({ space: 10 }) {
          Button('取消')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#EEF2F6')
            .fontColor('#7A8494')
            .onClick(() => {
              this.showSceneDialog = false;
            })

          Button('保存预设')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.saveScenePreset();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  AddSceneModeDialog() {
    Column() {
      Column({ space: 16 }) {
        Text('添加场景模式')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')

        TextInput({ placeholder: '例如：老人休息、影院、午睡', text: this.sceneModeDraftName })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.sceneModeDraftName = value;
          })

        Text('创建后即可为这个模式单独配置每个灯光、空调、窗帘和门禁设备。')
          .fontSize(12)
          .fontColor('#7A8494')
          .width('100%')

        Row({ space: 10 }) {
          Button('取消')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#EEF2F6')
            .fontColor('#7A8494')
            .onClick(() => {
              this.showAddSceneModeDialog = false;
              this.resetAddSceneModeDialog();
            })

          Button('创建')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.addSceneMode();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  UtilityDialog() {
    Column() {
      Column({ space: 16 }) {
        Text('生活缴费')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')

        Text('一个账号对应一份缴费数据，已接入 MySQL 持久化')
          .fontSize(12)
          .fontColor('#7A8494')
          .width('100%')

        Row({ space: 8 }) {
          this.UtilityTypeChip('electric')
          this.UtilityTypeChip('gas')
          this.UtilityTypeChip('water')
        }
        .width('100%')

        Column({ space: 8 }) {
          Text(this.utilityLabel(this.selectedUtilityType) + '当前余额')
            .fontSize(13)
            .fontColor('#7A8494')
            .width('100%')
          Text(this.utilityBalance(this.selectedUtilityType) + ' 元')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E2633')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        TextInput({ placeholder: '请输入充值金额，例如 50', text: this.utilityRechargeAmount })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.utilityRechargeAmount = value;
          })

        Row({ space: 8 }) {
          Button('50 元')
            .height(38)
            .layoutWeight(1)
            .borderRadius(12)
            .backgroundColor('#F4F6F9')
            .fontColor('#485D77')
            .onClick(() => {
              this.utilityQuickSet(50);
            })
          Button('100 元')
            .height(38)
            .layoutWeight(1)
            .borderRadius(12)
            .backgroundColor('#F4F6F9')
            .fontColor('#485D77')
            .onClick(() => {
              this.utilityQuickSet(100);
            })
          Button('200 元')
            .height(38)
            .layoutWeight(1)
            .borderRadius(12)
            .backgroundColor('#F4F6F9')
            .fontColor('#485D77')
            .onClick(() => {
              this.utilityQuickSet(200);
            })
        }
        .width('100%')

        Row({ space: 10 }) {
          Button('取消')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#EEF2F6')
            .fontColor('#7A8494')
            .onClick(() => {
              this.showUtilityDialog = false;
              this.utilityRechargeAmount = '';
            })

          Button('确认充值')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.rechargeUtility();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  FamilyDialog() {
    Column() {
      Column({ space: 16 }) {
        Text('家庭管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')

        Text('根据手机号把家人加入家庭，统一控制当前账号下的设备')
          .fontSize(12)
          .fontColor('#7A8494')
          .width('100%')

        if (this.familyMembers.length > 0) {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.familyMembers, (member: FamilyMemberInfo) => {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(member.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1E2633')
                      .width('100%')
                    Text(member.phone + ' · ' + member.roleLabel)
                      .fontSize(12)
                      .fontColor('#7A8494')
                      .width('100%')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .padding(14)
                .width('100%')
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
              }, (member: FamilyMemberInfo) => member.id.toString())
            }
            .width('100%')
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .width('100%')
          .constraintSize({ maxHeight: '34%' })
        }

        TextInput({ placeholder: '家人姓名', text: this.familyMemberName })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.familyMemberName = value;
          })

        TextInput({ placeholder: '11 位手机号', text: this.familyMemberPhone })
          .height(48)
          .fontSize(15)
          .backgroundColor('#F4F6F9')
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .type(InputType.PhoneNumber)
          .onChange((value: string) => {
            this.familyMemberPhone = value;
          })

        Row({ space: 10 }) {
          Button('取消')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#EEF2F6')
            .fontColor('#7A8494')
            .onClick(() => {
              this.showFamilyDialog = false;
              this.familyMemberName = '';
              this.familyMemberPhone = '';
            })

          Button('添加家人')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#7FAED6')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.addFamilyMemberFromDialog();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  @Builder
  DoorUnlockDialog() {
    Column() {
      Column({ space: 16 }) {
        Text('\u5165\u6237\u95e8\u6444\u50cf\u5934')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E2633')
        Text('\u67e5\u770b\u771f\u5b9e\u95e8\u53e3\u753b\u9762')
          .fontSize(13)
          .fontColor('#7A8494')
          .width('100%')

        if (this.doorCameraInfo !== null && this.doorCameraInfo.coverUrl.length > 0) {
          Stack() {
            Image(this.apiBaseUrl + this.doorCameraInfo.coverUrl)
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)

            if (this.doorCameraInfo.videoUrl.length > 0) {
              Video({
                src: this.apiBaseUrl + this.doorCameraInfo.videoUrl,
                controller: this.doorVideoController
              })
                .width('100%')
                .height(220)
                .borderRadius(16)
                .autoPlay(true)
                .controls(true)
                .muted(false)
                .loop(false)
                .objectFit(ImageFit.Cover)
            }
          }
        } else {
          Column() {
            Text('\u6682\u65e0\u89c6\u9891\u753b\u9762')
              .fontSize(15)
              .fontColor('#7A8494')
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height(180)
          .backgroundColor('#F4F6F9')
          .borderRadius(16)
        }

        if (this.currentDoorDialogDevice() !== undefined) {
          Text('\u8bb0\u5f55\u65f6\u95f4\uff1a' + this.cameraTimeText(this.doorCameraInfo ? this.doorCameraInfo.capturedAt : ''))
            .fontSize(12)
            .fontColor('#7A8494')
            .width('100%')
        }

        Row() {
          Button('\u5173\u95ed')
            .height(44)
            .layoutWeight(1)
            .borderRadius(14)
            .backgroundColor('#2E3441')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.closeDoorUnlockDialog();
            })
        }
        .width('100%')
      }
      .padding(20)
      .width('88%')
      .backgroundColor('#F9FAFC')
      .borderRadius(22)
      .shadow({ radius: 18, color: '#22000000', offsetX: 3, offsetY: 6 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#55000000')
  }

  aboutToAppear(): void {
    if (this.isLoggedIn) {
      this.startStatusRefresh();
      this.loadStatus();
    }
  }

  aboutToDisappear(): void {
    this.stopStatusRefresh();
  }

  build() {
    Stack() {
      if (this.isLoggedIn) {
        this.MainTabPage()
      } else {
        this.AuthPage()
      }

      if (this.showAddMenuDialog) {
        this.MenuDialog()
      }

      if (this.showAddDeviceDialog) {
        this.AddDeviceDialog()
      }

      if (this.showSceneDialog) {
        this.SceneDialog()
      }

      if (this.showAddSceneModeDialog) {
        this.AddSceneModeDialog()
      }

      if (this.showDoorUnlockDialog) {
        this.DoorUnlockDialog()
      }

      if (this.showUtilityDialog) {
        this.UtilityDialog()
      }

      if (this.showFamilyDialog) {
        this.FamilyDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2F6')
  }
}
