import { closeMainWindow } from "@vicinae/api";
import { spawn } from "node:child_process";

export default () => {
  closeMainWindow();
  spawn("noctalia-shell", ["ipc", "call", "settings", "openTab", "notifications"]);
};
