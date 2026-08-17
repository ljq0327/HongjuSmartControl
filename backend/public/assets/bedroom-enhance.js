const username = new URLSearchParams(window.location.search).get('username') || 'linjiaqi';
const SCENE_DEFS = [
  { key: 'primary', title: '主卧3D仿真', match: (room) => String(room.name || '').includes('主卧'), kind: 'primary' },
  { key: 'secondary', title: '次卧3D仿真', match: (room) => String(room.name || '').includes('次卧'), kind: 'secondary' },
  { key: 'living', title: '客厅3D仿真', match: (room) => String(room.name || '').includes('客厅') || String(room.id || '') === 'living', kind: 'living' }
];

let mountAttempts = 0;
let THREE = null;
let threeLoadPromise = null;

async function loadThree() {
  if (THREE) return THREE;
  if (!threeLoadPromise) {
    threeLoadPromise = import('/vendor/three.module.js').then((module) => {
      THREE = module;
      return THREE;
    });
  }
  return threeLoadPromise;
}

function el(tag, className, html) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (html !== undefined) node.innerHTML = html;
  return node;
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function percent(value, fallback = 0) {
  const numeric = Number(value);
  return Number.isFinite(numeric) ? clamp(numeric, 0, 100) : fallback;
}

function makeCanvasTexture(draw) {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 512;
  const ctx = canvas.getContext('2d');
  draw(ctx, canvas.width, canvas.height);
  const texture = new THREE.CanvasTexture(canvas);
  texture.wrapS = THREE.RepeatWrapping;
  texture.wrapT = THREE.RepeatWrapping;
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

function woodTexture() {
  return makeCanvasTexture((ctx, width, height) => {
    ctx.fillStyle = '#9c6a42';
    ctx.fillRect(0, 0, width, height);
    for (let y = 0; y < height; y += 34) {
      ctx.fillStyle = y % 68 === 0 ? 'rgba(255,235,190,.18)' : 'rgba(62,34,18,.2)';
      ctx.fillRect(0, y, width, 18);
      ctx.strokeStyle = 'rgba(55,32,18,.28)';
      ctx.beginPath();
      ctx.moveTo(0, y + 20);
      for (let x = 0; x <= width; x += 32) {
        ctx.lineTo(x, y + 20 + Math.sin((x + y) / 38) * 6);
      }
      ctx.stroke();
    }
  });
}

function fabricTexture(base, accent) {
  return makeCanvasTexture((ctx, width, height) => {
    ctx.fillStyle = base;
    ctx.fillRect(0, 0, width, height);
    ctx.strokeStyle = accent;
    for (let x = 0; x < width; x += 14) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x + 34, height);
      ctx.stroke();
    }
    ctx.globalAlpha = .32;
    for (let y = 0; y < height; y += 18) ctx.fillRect(0, y, width, 2);
  });
}

function wallTexture(color = '#d8d2c5') {
  return makeCanvasTexture((ctx, width, height) => {
    ctx.fillStyle = color;
    ctx.fillRect(0, 0, width, height);
    for (let i = 0; i < 2200; i += 1) {
      const light = 188 + Math.random() * 48;
      ctx.fillStyle = `rgba(${light},${light - 6},${light - 20},.12)`;
      ctx.fillRect(Math.random() * width, Math.random() * height, 1.4, 1.4);
    }
  });
}

function formatTime(value) {
  if (!value) return '--';
  return new Date(value).toLocaleTimeString('zh-CN', { hour12: false });
}

function summarizeRoom(room) {
  const devices = Array.isArray(room && room.devices) ? room.devices : [];
  const lights = devices.filter((device) => device.type === 'light');
  const poweredLights = lights.filter((device) => device.power);
  const light = poweredLights.length
    ? poweredLights.reduce((sum, device) => sum + percent(device.brightness, 88), 0) / poweredLights.length
    : 0;
  const curtain = devices.find((device) => device.type === 'curtain');
  const air = devices.find((device) => device.type === 'air');
  const speaker = devices.find((device) => device.type === 'speaker');
  const robot = devices.find((device) => device.type === 'robot');
  const tv = devices.find((device) => device.type === 'tv');
  return {
    roomName: room && room.name ? room.name : '房间',
    lights,
    light,
    curtain: curtain ? percent(curtain.brightness, curtain.power ? 60 : 0) : 0,
    hasCurtain: !!curtain,
    airOn: !!(air && air.power),
    temp: air && air.temperature ? air.temperature : 26,
    musicOn: !!(speaker && speaker.musicPlaying),
    speakerOn: !!(speaker && speaker.power),
    robotOn: !!(robot && robot.power),
    tvOn: !!(tv && tv.power),
    updatedAt: new Date().toISOString()
  };
}

function roomForScene(payload, sceneDef) {
  const rooms = payload && payload.data && Array.isArray(payload.data.rooms) ? payload.data.rooms : [];
  return rooms.find(sceneDef.match) || { name: sceneDef.title.replace('3D仿真', ''), devices: [] };
}

class RoomSimulation {
  constructor(container, hud, sceneDef) {
    this.container = container;
    this.hud = hud;
    this.sceneDef = sceneDef;
    this.clock = new THREE.Clock();
    this.pointer = { active: false, x: 0, y: 0, yaw: sceneDef.kind === 'living' ? -8 : 0, pitch: 22, distance: sceneDef.kind === 'living' ? 7.4 : 6.4 };
    this.roomTarget = new THREE.Vector3(0, 1.15, 0);
    this.state = { light: 0, curtain: 0, airOn: false, temp: 26, musicOn: false, robotOn: false, tvOn: false, lights: [] };
    this.lightFixtures = [];
    this.lightCount = 0;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x17201e);
    this.camera = new THREE.PerspectiveCamera(45, 1, .1, 100);
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false, preserveDrawingBuffer: true });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.container.appendChild(this.renderer.domElement);

    this.makeRoom();
    this.makeSceneFurniture();
    this.makeSharedDevices();
    this.bindControls();
    this.resize();
    this.animate();
  }

  material(color, roughness = .72, metalness = 0) {
    return new THREE.MeshStandardMaterial({ color, roughness, metalness });
  }

  textured(texture, repeatX, repeatY) {
    texture.repeat.set(repeatX, repeatY);
    return new THREE.MeshStandardMaterial({ map: texture, roughness: .78 });
  }

  addBox(size, position, material, cast = true, receive = true) {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(size[0], size[1], size[2]), material);
    mesh.position.set(position[0], position[1], position[2]);
    mesh.castShadow = cast;
    mesh.receiveShadow = receive;
    this.scene.add(mesh);
    return mesh;
  }

  addCylinder(radiusTop, radiusBottom, height, position, material, segments = 40) {
    const mesh = new THREE.Mesh(new THREE.CylinderGeometry(radiusTop, radiusBottom, height, segments), material);
    mesh.position.set(position[0], position[1], position[2]);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    this.scene.add(mesh);
    return mesh;
  }

  makeRoom() {
    const wallColor = this.sceneDef.kind === 'living' ? '#d4d1c4' : (this.sceneDef.kind === 'secondary' ? '#dcd7cc' : '#d8d2c5');
    const wallMat = this.textured(wallTexture(wallColor), 3, 2);
    const floorMat = this.textured(woodTexture(), 4, 3);
    const ceilingMat = this.material(0xf0eee6, .8);
    ceilingMat.transparent = true;
    ceilingMat.opacity = .36;

    const width = this.sceneDef.kind === 'living' ? 8.6 : 7.6;
    const depth = this.sceneDef.kind === 'living' ? 6.2 : 5.8;
    this.addBox([width, .14, depth], [0, -.07, 0], floorMat, false, true);
    this.addBox([width, 3.2, .16], [0, 1.6, -depth / 2], wallMat, false, true);
    this.addBox([.16, 3.2, depth], [-width / 2, 1.6, 0], wallMat, false, true);
    this.addBox([.16, 3.2, depth], [width / 2, 1.6, 0], wallMat, false, true);
    this.addBox([width, .12, depth], [0, 3.22, 0], ceilingMat, false, true);

    this.ambient = new THREE.HemisphereLight(0xfff4dc, 0x273c40, .72);
    this.scene.add(this.ambient);
    this.keyLight = new THREE.DirectionalLight(0xffeed4, 1.05);
    this.keyLight.position.set(-2.5, 4.6, 2.5);
    this.keyLight.castShadow = true;
    this.keyLight.shadow.mapSize.set(1024, 1024);
    this.scene.add(this.keyLight);
  }

  makeSceneFurniture() {
    if (this.sceneDef.kind === 'living') {
      this.makeLivingRoom();
    } else if (this.sceneDef.kind === 'secondary') {
      this.makeSecondaryBedroom();
    } else {
      this.makePrimaryBedroom();
    }
  }

  makePrimaryBedroom() {
    const wood = this.textured(woodTexture(), 1.2, 1.2);
    const blanket = this.textured(fabricTexture('#496b70', 'rgba(245,255,245,.18)'), 1.5, 1.5);
    const sheet = this.material(0xf1eadf, .82);
    const pillow = this.material(0xf7f3ea, .72);
    this.addBox([2.35, .38, 2.65], [-1.35, .28, -.85], wood);
    this.addBox([2.22, .26, 2.48], [-1.35, .62, -.7], sheet);
    this.addBox([2.1, .18, 1.52], [-1.35, .82, -.06], blanket);
    this.addBox([2.55, 1.05, .22], [-1.35, .82, -2.34], wood);
    this.addBox([.86, .18, .48], [-1.88, .86, -1.62], pillow);
    this.addBox([.86, .18, .48], [-.82, .86, -1.62], pillow);
    this.addBox([.68, .58, .55], [-2.92, .29, -1.76], wood);
    this.addBox([.68, .58, .55], [.22, .29, -1.76], wood);
    this.makeTableLamp(-2.92, -1.76);
    this.makeTableLamp(.22, -1.76);
    this.addBox([1.22, 2.45, .55], [3.05, 1.22, -1.95], wood);
    this.addBox([1.55, .16, .78], [2.35, .86, 1.85], wood);
    this.addBox([.74, .14, .66], [1.8, .47, 2.62], this.material(0x59676a, .68));
    this.addBox([.74, .82, .12], [1.8, .9, 2.93], this.material(0x59676a, .68));
    this.addRug([2.65, .04, 1.7], [.55, .025, 1.12], '#9f4f44');
  }

  makeSecondaryBedroom() {
    const wood = this.textured(woodTexture(), 1.2, 1.2);
    const blanket = this.textured(fabricTexture('#7a8558', 'rgba(255,245,210,.2)'), 1.4, 1.4);
    const sheet = this.material(0xf1eadf, .82);
    this.addBox([1.45, .34, 2.35], [-2.08, .26, -.8], wood);
    this.addBox([1.34, .24, 2.22], [-2.08, .56, -.65], sheet);
    this.addBox([1.26, .16, 1.38], [-2.08, .76, .05], blanket);
    this.addBox([1.6, .9, .2], [-2.08, .75, -2.25], wood);
    this.addBox([.78, .18, .46], [-2.08, .82, -1.55], this.material(0xf7f3ea, .72));
    this.addBox([1.75, .16, .82], [1.65, .84, -1.95], wood);
    this.addBox([.08, .78, .08], [.9, .42, -2.23], wood);
    this.addBox([.08, .78, .08], [2.4, .42, -1.65], wood);
    this.addBox([.8, .14, .68], [1.55, .44, -1.05], this.material(0x697072, .68));
    this.addBox([.8, .8, .12], [1.55, .87, -.75], this.material(0x697072, .68));
    this.addBox([1.18, 2.25, .5], [3.0, 1.13, .85], wood);
    this.addRug([2.3, .04, 1.45], [.1, .025, 1.25], '#516a83');
  }

  makeLivingRoom() {
    const wood = this.textured(woodTexture(), 1.2, 1.2);
    const sofaMat = this.textured(fabricTexture('#4f6670', 'rgba(230,245,245,.2)'), 1.8, 1.2);
    const wallPanel = this.material(0x3d3931, .62);
    this.addBox([3.4, .55, .9], [-1.65, .38, 1.72], sofaMat);
    this.addBox([3.5, 1.0, .28], [-1.65, .9, 2.18], sofaMat);
    this.addBox([.52, .72, .95], [-3.68, .55, 1.72], sofaMat);
    this.addBox([.52, .72, .95], [.38, .55, 1.72], sofaMat);
    this.addBox([1.65, .22, .88], [-1.32, .5, .38], wood);
    this.addBox([.1, .5, .1], [-2.0, .23, .05], wood);
    this.addBox([.1, .5, .1], [-.65, .23, .7], wood);
    this.addBox([2.85, 1.58, .16], [2.35, 1.62, -2.88], wallPanel);
    this.tvScreen = this.addBox([2.12, 1.08, .08], [2.35, 1.66, -2.76], this.material(0x05090b, .35));
    this.tvScreen.material.emissive = new THREE.Color(0x00151f);
    this.addBox([2.35, .48, .55], [2.35, .24, -2.22], wood);
    this.addBox([1.2, 1.8, .45], [3.62, .9, .72], wood);
    this.addRug([3.5, .04, 2.1], [-1.05, .025, .55], '#8a493e');
  }

  makeTableLamp(x, z) {
    const pole = this.addCylinder(.035, .035, .45, [x, .89, z], this.material(0xb89c72, .36, .18), 18);
    pole.rotation.y = Math.PI / 6;
    const shade = new THREE.Mesh(new THREE.ConeGeometry(.22, .3, 24, 1, true), this.material(0xf3d49a, .58));
    shade.position.set(x, 1.16, z);
    shade.castShadow = true;
    this.scene.add(shade);
  }

  addRug(size, position, color) {
    const rugMat = this.textured(fabricTexture(color, 'rgba(255,230,200,.22)'), 2, 1);
    const rug = new THREE.Mesh(new THREE.BoxGeometry(size[0], size[1], size[2]), rugMat);
    rug.position.set(position[0], position[1], position[2]);
    rug.receiveShadow = true;
    this.scene.add(rug);
  }

  makeSharedDevices() {
    this.makeWindowAndCurtains();
    this.makeAirConditioner();
    this.makeSpeakerAndRobot();
  }

  makeWindowAndCurtains() {
    const glass = new THREE.MeshStandardMaterial({ color: 0xa8d7ff, roughness: .14, transparent: true, opacity: .55 });
    const frame = this.material(0xede6d7, .52);
    const x = this.sceneDef.kind === 'living' ? -3.1 : 1.45;
    const z = -2.805;
    const width = this.sceneDef.kind === 'living' ? 2.35 : 1.85;
    this.addBox([width, 1.3, .04], [x, 1.82, z], glass, false, false);
    this.addBox([width + .22, .08, .09], [x, 2.5, -2.72], frame);
    this.addBox([width + .22, .08, .09], [x, 1.14, -2.72], frame);
    this.addBox([.08, 1.44, .09], [x - width / 2 - .08, 1.82, -2.72], frame);
    this.addBox([.08, 1.44, .09], [x + width / 2 + .08, 1.82, -2.72], frame);
    this.addBox([.06, 1.34, .08], [x, 1.82, -2.70], frame);
    const curtainMat = this.textured(fabricTexture(this.sceneDef.kind === 'living' ? '#b57a55' : '#c98572', 'rgba(255,240,220,.28)'), 1, 2);
    curtainMat.transparent = true;
    this.curtainLeft = this.addBox([.76, 1.55, .08], [x - .42, 1.8, -2.58], curtainMat);
    this.curtainRight = this.addBox([.76, 1.55, .08], [x + .42, 1.8, -2.58], curtainMat);
    this.curtainBase = { left: x - .42, right: x + .42 };
  }

  makeAirConditioner() {
    this.addBox([1.12, .34, .22], [-.12, 2.55, -2.66], this.material(0xf4f1e8, .45));
    this.fan = new THREE.Group();
    const fanMat = this.material(0xa9b2b3, .36, .1);
    for (let i = 0; i < 3; i += 1) {
      const blade = new THREE.Mesh(new THREE.BoxGeometry(.04, .32, .012), fanMat);
      blade.position.y = .1;
      blade.rotation.z = i * Math.PI * 2 / 3;
      this.fan.add(blade);
    }
    this.fan.position.set(-.12, 2.42, -2.51);
    this.scene.add(this.fan);
  }

  makeSpeakerAndRobot() {
    const speakerX = this.sceneDef.kind === 'living' ? -3.55 : .22;
    const speakerZ = this.sceneDef.kind === 'living' ? -.85 : -1.76;
    this.speaker = this.addCylinder(.18, .18, .54, [speakerX, .96, speakerZ], this.material(0x25282a, .5), 32);
    this.speakerRing = new THREE.Mesh(
      new THREE.TorusGeometry(.19, .012, 10, 40),
      new THREE.MeshStandardMaterial({ color: 0x8fe0d4, emissive: 0x77d7c9, emissiveIntensity: .22 })
    );
    this.speakerRing.position.set(speakerX, 1.24, speakerZ);
    this.speakerRing.rotation.x = Math.PI / 2;
    this.scene.add(this.speakerRing);

    this.robot = this.addCylinder(.28, .28, .14, [.9, .13, 1.15], this.material(0xced4d0, .42), 48);
    const robotTop = new THREE.Mesh(new THREE.CylinderGeometry(.16, .16, .035, 32), this.material(0x2e3a3b, .32));
    robotTop.position.set(0, .09, 0);
    this.robot.add(robotTop);
  }

  syncLightFixtures(lights) {
    const count = Math.max(1, lights.length);
    if (count === this.lightCount) return;
    this.lightFixtures.forEach((item) => {
      this.scene.remove(item.light);
      this.scene.remove(item.disc);
      item.disc.geometry.dispose();
      item.disc.material.dispose();
    });
    this.lightFixtures = [];
    this.lightCount = count;
    const spread = this.sceneDef.kind === 'living' ? 2.6 : 1.8;
    for (let i = 0; i < count; i += 1) {
      const x = count === 1 ? 0 : -spread / 2 + (spread * i) / (count - 1);
      const z = this.sceneDef.kind === 'living' ? -.15 : .15;
      const light = new THREE.PointLight(0xffdf9a, 1.8, 9, 1.6);
      light.position.set(x, 3.02, z);
      light.castShadow = true;
      this.scene.add(light);
      const disc = new THREE.Mesh(
        new THREE.CylinderGeometry(.3, .3, .08, 40),
        new THREE.MeshStandardMaterial({ color: 0xffe3a1, emissive: 0xffcc70, emissiveIntensity: .45, roughness: .28 })
      );
      disc.position.set(x, 3.13, z);
      this.scene.add(disc);
      this.lightFixtures.push({ light, disc });
    }
  }

  bindControls() {
    const canvas = this.renderer.domElement;
    canvas.addEventListener('pointerdown', (event) => {
      this.pointer.active = true;
      this.pointer.x = event.clientX;
      this.pointer.y = event.clientY;
      canvas.setPointerCapture(event.pointerId);
    });
    canvas.addEventListener('pointermove', (event) => {
      if (!this.pointer.active) return;
      const dx = event.clientX - this.pointer.x;
      const dy = event.clientY - this.pointer.y;
      this.pointer.x = event.clientX;
      this.pointer.y = event.clientY;
      this.pointer.yaw -= dx * .25;
      this.pointer.pitch = clamp(this.pointer.pitch + dy * .18, -6, 45);
      this.updateCamera();
    });
    canvas.addEventListener('pointerup', (event) => {
      this.pointer.active = false;
      try { canvas.releasePointerCapture(event.pointerId); } catch {}
    });
    canvas.addEventListener('wheel', (event) => {
      event.preventDefault();
      this.pointer.distance = clamp(this.pointer.distance + event.deltaY * .004, 5.4, 11);
      this.updateCamera();
    }, { passive: false });
    window.addEventListener('resize', () => this.resize());
  }

  updateCamera() {
    const yaw = THREE.MathUtils.degToRad(this.pointer.yaw);
    const pitch = THREE.MathUtils.degToRad(this.pointer.pitch);
    const radius = this.pointer.distance;
    this.camera.position.set(
      Math.sin(yaw) * Math.cos(pitch) * radius,
      1.2 + Math.sin(pitch) * radius,
      Math.cos(yaw) * Math.cos(pitch) * radius
    );
    this.camera.lookAt(this.roomTarget);
  }

  resize() {
    const rect = this.container.getBoundingClientRect();
    const width = Math.max(320, rect.width || window.innerWidth);
    const height = Math.max(520, rect.height || window.innerHeight - 92);
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height, false);
    this.updateCamera();
  }

  apply(model) {
    this.state = { ...this.state, ...model };
    this.syncLightFixtures(model.lights || []);
    const averageRatio = clamp(this.state.light / 100, 0, 1);
    this.ambient.intensity = .28 + averageRatio * .75;
    this.keyLight.intensity = .42 + averageRatio * 1.05;
    this.lightFixtures.forEach((fixture, index) => {
      const device = this.state.lights[index];
      const value = device && device.power ? percent(device.brightness, 88) : 0;
      const ratio = clamp(value / 100, 0, 1);
      fixture.light.intensity = .18 + ratio * 4.2;
      fixture.disc.material.emissiveIntensity = .1 + ratio * 1.25;
      fixture.disc.material.color.set(ratio > 0 ? 0xffe3a1 : 0x8c806c);
    });

    const openness = clamp(this.state.curtain / 100, 0, 1);
    this.curtainLeft.position.x = this.curtainBase.left - openness * .5;
    this.curtainRight.position.x = this.curtainBase.right + openness * .5;
    this.curtainLeft.scale.x = 1 - openness * .25;
    this.curtainRight.scale.x = 1 - openness * .25;
    this.curtainLeft.material.opacity = .94 - openness * .2;
    this.curtainRight.material.opacity = .94 - openness * .2;

    if (this.tvScreen) {
      this.tvScreen.material.emissive = new THREE.Color(this.state.tvOn ? 0x1278b8 : 0x00151f);
      this.tvScreen.material.emissiveIntensity = this.state.tvOn ? .7 : .08;
    }
    this.updateHud(model);
  }

  updateHud(model) {
    this.hud.light.textContent = `${Math.round(this.state.light)}% / ${this.state.lights.length}盏`;
    this.hud.curtain.textContent = this.state.hasCurtain ? `${Math.round(this.state.curtain)}%` : '无';
    this.hud.air.textContent = this.state.airOn ? `${this.state.temp || 26}°C` : '关闭';
    this.hud.robot.textContent = this.state.robotOn ? '清扫中' : '待命';
    this.hud.music.textContent = this.state.musicOn ? '播放中' : (this.state.speakerOn ? '待机' : '无');
    this.hud.tv.textContent = this.sceneDef.kind === 'living' ? (this.state.tvOn ? '开启' : '关闭') : '无';
    this.hud.updated.textContent = formatTime(model.updatedAt);
    Object.entries(this.hud.chips).forEach(([key, node]) => {
      const activeMap = {
        light: this.state.light > 0,
        curtain: this.state.hasCurtain && this.state.curtain > 30,
        air: this.state.airOn,
        robot: this.state.robotOn,
        music: this.state.musicOn,
        tv: this.state.tvOn
      };
      if (node) node.classList.toggle('active', !!activeMap[key]);
    });
  }

  animate() {
    requestAnimationFrame(() => this.animate());
    const dt = this.clock.getDelta();
    if (this.state.airOn && this.fan) this.fan.rotation.z += dt * 9;
    if (this.state.robotOn && this.robot) {
      const t = performance.now() * .00045;
      this.robot.position.x = .2 + Math.sin(t * 1.6) * (this.sceneDef.kind === 'living' ? 2.5 : 1.8);
      this.robot.position.z = 1.08 + Math.cos(t * 1.15) * (this.sceneDef.kind === 'living' ? 1.25 : .95);
      this.robot.rotation.y += dt * 2.8;
    }
    if (this.state.musicOn && this.speakerRing) {
      const pulse = 1 + Math.sin(performance.now() * .008) * .08;
      this.speakerRing.scale.setScalar(pulse);
      this.speakerRing.material.emissiveIntensity = .45 + Math.abs(Math.sin(performance.now() * .006)) * .6;
    } else if (this.speakerRing) {
      this.speakerRing.scale.setScalar(1);
      this.speakerRing.material.emissiveIntensity = .22;
    }
    this.renderer.render(this.scene, this.camera);
  }
}

function makeSimulationView(sceneDef) {
  const view = el('section', 'hm-view hm-sim-view');
  view.hidden = true;
  view.dataset.scene = sceneDef.key;
  view.innerHTML = `
    <header class="hm-sim-header">
      <div>
        <h2 class="hm-sim-title">${sceneDef.title}</h2>
        <p class="hm-sim-copy">房间模型按当前后端设备实时驱动，灯具数量会和 APP 中该房间的灯光设备数量保持一致。</p>
      </div>
      <div class="hm-sim-hud">
        <span class="hm-chip" data-chip="light">灯光 <strong data-value="light">--</strong></span>
        <span class="hm-chip" data-chip="curtain">窗帘 <strong data-value="curtain">--</strong></span>
        <span class="hm-chip" data-chip="air">空调 <strong data-value="air">--</strong></span>
        <span class="hm-chip" data-chip="robot">机器人 <strong data-value="robot">--</strong></span>
        <span class="hm-chip" data-chip="tv">电视 <strong data-value="tv">--</strong></span>
      </div>
    </header>
    <div class="hm-sim-canvas-wrap" data-canvas>
      <div class="hm-sim-overlay">
        <div class="hm-status-panel">
          <h3>实时设备状态</h3>
          <div class="hm-status-grid">
            <div class="hm-status-item"><span>灯光亮度 / 数量</span><strong data-value="light">--</strong></div>
            <div class="hm-status-item"><span>窗帘开合</span><strong data-value="curtain">--</strong></div>
            <div class="hm-status-item"><span>空调状态</span><strong data-value="air">--</strong></div>
            <div class="hm-status-item"><span>扫地机器人</span><strong data-value="robot">--</strong></div>
            <div class="hm-status-item"><span>音箱音乐</span><strong data-value="music">--</strong></div>
            <div class="hm-status-item"><span>电视状态</span><strong data-value="tv">--</strong></div>
          </div>
          <p class="hm-sim-copy">最后同步：<span data-value="updated">--</span></p>
        </div>
      </div>
    </div>
  `;
  return view;
}

function makeHud(view) {
  const buckets = {};
  view.querySelectorAll('[data-value]').forEach((node) => {
    const key = node.dataset.value;
    if (!buckets[key]) buckets[key] = [];
    buckets[key].push(node);
  });
  const bind = (key) => ({ set textContent(value) { (buckets[key] || []).forEach((node) => { node.textContent = value; }); } });
  return {
    light: bind('light'),
    curtain: bind('curtain'),
    air: bind('air'),
    robot: bind('robot'),
    music: bind('music'),
    tv: bind('tv'),
    updated: bind('updated'),
    chips: {
      light: view.querySelector('[data-chip="light"]'),
      curtain: view.querySelector('[data-chip="curtain"]'),
      air: view.querySelector('[data-chip="air"]'),
      robot: view.querySelector('[data-chip="robot"]'),
      music: null,
      tv: view.querySelector('[data-chip="tv"]')
    }
  };
}

function buildShell() {
  if (document.body.classList.contains('hm-enhanced')) return null;
  const legacyMain = document.querySelector('body > main') || document.querySelector('main');
  if (!legacyMain) return null;

  document.body.classList.add('hm-enhanced');
  document.title = '鸿居智控 - 数字孪生网页端';
  const shell = el('div', 'hm-shell');
  const sidebar = el('aside', 'hm-sidebar', `
    <div class="hm-brand">
      <div class="hm-brand-mark">鸿</div>
      <div>
        <div class="hm-brand-title">鸿居数字孪生</div>
        <div class="hm-brand-subtitle">网页端实时仿真</div>
      </div>
    </div>
    <nav class="hm-nav" aria-label="页面菜单">
      <button type="button" class="active" data-view="legacy"><span class="hm-nav-icon">页</span><span>全览页面</span></button>
      <button type="button" data-view="primary"><span class="hm-nav-icon">主</span><span>主卧3D仿真</span></button>
      <button type="button" data-view="secondary"><span class="hm-nav-icon">次</span><span>次卧3D仿真</span></button>
      <button type="button" data-view="living"><span class="hm-nav-icon">客</span><span>客厅3D仿真</span></button>
    </nav>
    <div class="hm-sidebar-footer">切换不同房间的 3D 仿真，APP 操作会通过后端实时同步到对应场景。</div>
  `);
  const stage = el('div', 'hm-stage');
  const legacyView = el('section', 'hm-view legacy-view');
  const sceneViews = {};
  document.body.prepend(shell);
  shell.append(sidebar, stage);
  legacyView.appendChild(legacyMain);
  stage.appendChild(legacyView);
  SCENE_DEFS.forEach((sceneDef) => {
    const view = makeSimulationView(sceneDef);
    sceneViews[sceneDef.key] = view;
    stage.appendChild(view);
  });
  return { sidebar, legacyView, sceneViews };
}

async function fetchPayload() {
  const response = await fetch(`/api/status?username=${encodeURIComponent(username)}`, { cache: 'no-store' });
  if (!response.ok) throw new Error('status failed');
  const payload = await response.json();
  if (!payload.success) throw new Error('status failed');
  return payload;
}

function init() {
  const shell = buildShell();
  if (!shell) {
    mountAttempts += 1;
    if (mountAttempts < 40) window.setTimeout(init, 100);
    return;
  }

  const simulations = {};
  SCENE_DEFS.forEach((sceneDef) => {
    const view = shell.sceneViews[sceneDef.key];
    simulations[sceneDef.key] = {
      def: sceneDef,
      view,
      hud: makeHud(view),
      sim: null
    };
  });

  let latestPayload = null;
  let currentView = 'legacy';

  function applyPayloadToSimulation(item, payload) {
    if (!item.sim || !payload) return;
    const room = roomForScene(payload, item.def);
    const model = summarizeRoom(room);
    model.updatedAt = payload.data && payload.data.updatedAt ? payload.data.updatedAt : new Date().toISOString();
    item.sim.apply(model);
  }

  async function ensureSimulation(item) {
    if (item.sim) return item.sim;
    item.hud.updated.textContent = '3D loading';
    await loadThree();
    item.sim = new RoomSimulation(item.view.querySelector('[data-canvas]'), item.hud, item.def);
    applyPayloadToSimulation(item, latestPayload);
    return item.sim;
  }

  async function activateView(viewKey) {
    currentView = viewKey;
    shell.sidebar.querySelectorAll('[data-view]').forEach((item) => item.classList.toggle('active', item.dataset.view === viewKey));
    shell.legacyView.hidden = currentView !== 'legacy';
    Object.values(simulations).forEach((item) => {
      item.view.hidden = currentView !== item.def.key;
    });

    const item = simulations[currentView];
    if (!item) return;
    try {
      const sim = await ensureSimulation(item);
      if (currentView === item.def.key) requestAnimationFrame(() => sim.resize());
    } catch {
      item.hud.updated.textContent = '3D failed';
    }
  }

  shell.sidebar.querySelectorAll('[data-view]').forEach((button) => {
    button.addEventListener('click', () => {
      activateView(button.dataset.view);
    });
  });

  async function sync() {
    try {
      const payload = await fetchPayload();
      latestPayload = payload;
      Object.values(simulations).forEach((item) => applyPayloadToSimulation(item, payload));
    } catch {
      Object.values(simulations).forEach((item) => {
        if (!item.sim) return;
        item.sim.hud.updated.textContent = '后端未连接';
      });
    }
  }

  sync();
  setInterval(sync, 1200);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
