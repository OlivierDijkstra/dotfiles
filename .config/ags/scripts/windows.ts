import { App, type Widget } from "astal/gtk3";
import { ControlPanel } from "../widget/ControlPanel";

class WindowManager {
	private static instance: WindowManager;
	private openWindows: Record<string, Widget.Window> = {};

	public static getInstance(): WindowManager {
		if (!WindowManager.instance) {
			WindowManager.instance = new WindowManager();
		}
		return WindowManager.instance;
	}

	private getMonitorId(): number {
		return 0; // For now, just use monitor 0
	}

	public isVisible(name: string): boolean {
		return Boolean(this.openWindows[name]?.visible);
	}

	public open(name: string): void {
		if (this.isVisible(name)) return;

		let window: Widget.Window;

		switch (name) {
			case "control-panel":
				window = ControlPanel(this.getMonitorId());
				break;
			default:
				console.warn(`Unknown window: ${name}`);
				return;
		}

		this.openWindows[name] = window;

		// Set up cleanup when window is destroyed
		window.connect("destroy", () => {
			delete this.openWindows[name];
		});

		window.show();
	}

	public close(name: string): void {
		if (!this.isVisible(name)) return;

		this.openWindows[name].close();
		delete this.openWindows[name];
	}

	public toggle(name: string): void {
		if (this.isVisible(name)) {
			this.close(name);
		} else {
			this.open(name);
		}
	}

	public closeAll(): void {
		for (const name of Object.keys(this.openWindows)) {
			this.close(name);
		}
	}
}

export const Windows = WindowManager.getInstance();
