const commands = {
  posix: {
    standard: {
      title: "macOS / Linux · 标准安装",
      command: "curl -LsSf https://deepy.kirineko.tech/install.sh | sh",
      script: "/install.sh",
    },
    china: {
      title: "macOS / Linux · 中国镜像加速",
      command: "curl -LsSf https://deepy.kirineko.tech/install-zh.sh | sh",
      script: "/install-zh.sh",
    },
  },
  windows: {
    standard: {
      title: "Windows PowerShell · 标准安装",
      command: "irm https://deepy.kirineko.tech/install.ps1 | iex",
      script: "/install.ps1",
    },
    china: {
      title: "Windows PowerShell · 中国镜像加速",
      command: "irm https://deepy.kirineko.tech/install-zh.ps1 | iex",
      script: "/install-zh.ps1",
    },
  },
};

function detectOs() {
  const platform = [
    navigator.userAgentData?.platform,
    navigator.platform,
    navigator.userAgent,
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  if (platform.includes("mac") || platform.includes("linux")) {
    return "posix";
  }

  return "windows";
}

let activeOs = detectOs();
let activeMode = "china";

const osButtons = document.querySelectorAll("[data-os]");
const modeButtons = document.querySelectorAll("[data-mode]");
const commandTitle = document.querySelector("#commandTitle");
const installCommand = document.querySelector("#installCommand");
const scriptLink = document.querySelector("#scriptLink");
const copyCommand = document.querySelector("#copyCommand");

function setButtonState(buttons, key, attr) {
  buttons.forEach((button) => {
    const active = button.dataset[attr] === key;
    button.classList.toggle("is-active", active);
    if (button.getAttribute("role") === "tab") {
      button.setAttribute("aria-selected", String(active));
    }
  });
}

function renderCommand() {
  const selected = commands[activeOs][activeMode];
  commandTitle.textContent = selected.title;
  installCommand.textContent = selected.command;
  scriptLink.href = selected.script;
  copyCommand.textContent = "复制命令";
  setButtonState(osButtons, activeOs, "os");
  setButtonState(modeButtons, activeMode, "mode");
}

osButtons.forEach((button) => {
  button.addEventListener("click", () => {
    activeOs = button.dataset.os;
    setButtonState(osButtons, activeOs, "os");
    renderCommand();
  });
});

modeButtons.forEach((button) => {
  button.addEventListener("click", () => {
    activeMode = button.dataset.mode;
    setButtonState(modeButtons, activeMode, "mode");
    renderCommand();
  });
});

copyCommand.addEventListener("click", async () => {
  const text = installCommand.textContent;
  try {
    await navigator.clipboard.writeText(text);
    copyCommand.textContent = "已复制";
  } catch {
    copyCommand.textContent = "手动复制";
  }
});

renderCommand();
