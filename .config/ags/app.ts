import { App } from "astal/gtk3";
import type { Widget } from "astal/gtk3";
import style from "./style.scss";
import Bar from "./widget/Bar";

// Store active bar windows
const barWindows = new Map<number, Widget.Window>();

function createBar(monitor: number) {
	try {
		// Remove existing bar for this monitor if it exists
		if (barWindows.has(monitor)) {
			const existingBar = barWindows.get(monitor);
			try {
				existingBar?.destroy();
			} catch (error) {
				print(
					`Warning: Could not destroy existing bar for monitor ${monitor}: ${error}`,
				);
			}
			barWindows.delete(monitor);
		}

		// Create new bar
		const bar = Bar(monitor);
		barWindows.set(monitor, bar);
		print(`Created bar for monitor ${monitor}`);
		return bar;
	} catch (error) {
		print(`Error creating bar for monitor ${monitor}: ${error}`);
		return null;
	}
}

function recreateBarsWithRetry(retryCount = 0, maxRetries = 5) {
	try {
		const monitors = App.get_monitors();

		if (monitors.length === 0 && retryCount < maxRetries) {
			print(
				`No monitors detected (attempt ${retryCount + 1}/${maxRetries}), retrying in 200ms...`,
			);
			setTimeout(() => recreateBarsWithRetry(retryCount + 1, maxRetries), 200);
			return;
		}

		if (monitors.length === 0) {
			print("No monitors detected after maximum retries");
			return;
		}

		print(`Recreating bars for ${monitors.length} monitors...`);

		// Clear all existing bars first
		barWindows.forEach((bar, monitor) => {
			try {
				bar?.destroy();
				print(`Destroyed bar for monitor ${monitor}`);
			} catch (error) {
				print(`Error destroying bar for monitor ${monitor}: ${error}`);
			}
		});
		barWindows.clear();

		// Create new bars
		monitors.forEach((_, i) => createBar(i));

		print(`Successfully recreated bars for ${monitors.length} monitors`);
	} catch (error) {
		print(`Error in recreateBarsWithRetry: ${error}`);

		// If we still have retries left, try again
		if (retryCount < maxRetries) {
			setTimeout(() => recreateBarsWithRetry(retryCount + 1, maxRetries), 500);
		}
	}
}

function handleMonitorChange() {
	print("Monitor configuration changed, starting recreation...");
	recreateBarsWithRetry();
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
				print("Monitor added event detected");
				// Larger delay to ensure monitor is fully ready
				setTimeout(handleMonitorChange, 500);
			});

			display.connect("monitor-removed", () => {
				print("Monitor removed event detected");
				// Immediate response to removal
				setTimeout(handleMonitorChange, 100);
			});
		}

		print(
			`AGS started with monitor handling for ${App.get_monitors().length} monitors`,
		);
	},
});
