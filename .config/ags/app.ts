import { App } from "astal/gtk3";
import type { Widget } from "astal/gtk3";
import style from "./style.scss";
import Bar from "./widget/Bar";

// Store active bar windows
const barWindows = new Map<number, Widget.Window>();

function createBar(monitor: number) {
	// Remove existing bar for this monitor if it exists
	if (barWindows.has(monitor)) {
		const existingBar = barWindows.get(monitor);
		existingBar?.destroy();
		barWindows.delete(monitor);
	}

	// Create new bar
	const bar = Bar(monitor);
	barWindows.set(monitor, bar);
	return bar;
}

function handleMonitorChange() {
	print("Monitor configuration changed, recreating bars...");

	// Clear all existing bars
	barWindows.forEach((bar, monitor) => {
		try {
			bar?.destroy();
		} catch (error) {
			print(`Error destroying bar for monitor ${monitor}: ${error}`);
		}
	});
	barWindows.clear();

	// Recreate bars for all current monitors
	try {
		const monitors = App.get_monitors();
		monitors.forEach((_, i) => createBar(i));
		print(`Created bars for ${monitors.length} monitors`);
	} catch (error) {
		print(`Error recreating bars: ${error}`);
	}
}

App.start({
	css: style,
	main() {
		// Create initial bars
		App.get_monitors().forEach((_, i) => createBar(i));

		// Monitor for display changes
		const display = App.get_monitors()[0]?.get_display();
		if (display) {
			display.connect("monitor-added", () => {
				// Small delay to ensure monitor is fully initialized
				setTimeout(handleMonitorChange, 100);
			});

			display.connect("monitor-removed", () => {
				// Small delay to ensure monitor removal is processed
				setTimeout(handleMonitorChange, 100);
			});
		}

		print("AGS started with monitor handling");
	},
});
