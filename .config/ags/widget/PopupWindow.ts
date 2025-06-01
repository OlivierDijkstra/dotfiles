import { Binding } from "astal";
import { Astal, Gdk, type Gtk, Widget } from "astal/gtk3";

type PopupWindowSpecificProps = {
	onDestroy?: (self: Widget.Window) => void;
	onKeyPressEvent?: (self: Widget.Window, event: Gdk.Event) => void;
	onButtonPressEvent?: (self: Gtk.Widget, event: Gdk.Event) => void;
	onClickedOutside?: (self: Widget.Window) => void;
};

export type PopupWindowProps = Pick<
	Widget.WindowProps,
	| "child"
	| "monitor"
	| "css"
	| "layer"
	| "exclusivity"
	| "marginLeft"
	| "marginTop"
	| "marginRight"
	| "marginBottom"
	| "expand"
	| "cursor"
	| "canFocus"
	| "hasFocus"
	| "tooltipMarkup"
	| "namespace"
	| "widthRequest"
	| "heightRequest"
	| "halign"
	| "valign"
	| "vexpand"
	| "hexpand"
> &
	PopupWindowSpecificProps;

const { TOP, LEFT, RIGHT, BOTTOM } = Astal.WindowAnchor;

export function PopupWindow(props: PopupWindowProps): Widget.Window {
	props.layer = props.layer ?? Astal.Layer.OVERLAY;

	return new Widget.Window({
		...props,
		namespace: props?.namespace ?? "popup-window",
		className: `popup-window ${
			(props.namespace instanceof Binding
				? props.namespace.get()
				: props.namespace) || ""
		}`,
		keymode: Astal.Keymode.EXCLUSIVE,
		anchor: TOP | LEFT | RIGHT | BOTTOM,
		exclusivity: props.exclusivity ?? Astal.Exclusivity.NORMAL,
		halign: undefined,
		valign: undefined,
		focusOnMap: true,
		widthRequest: undefined,
		heightRequest: undefined,
		marginTop: undefined,
		marginBottom: undefined,
		marginLeft: undefined,
		marginRight: undefined,
		onDestroy: (self) => {
			props.onDestroy?.(self);
		},
		onButtonPressEvent: (self, event) => {
			if (
				event.get_button()[1] === Gdk.BUTTON_PRIMARY ||
				event.get_button()[1] === Gdk.BUTTON_SECONDARY
			) {
				const [, x, y] = event.get_coords();
				const child = self.get_child();
				if (!child) return;

				const box = child as Widget.Box;
				const innerChild = box.get_child();
				if (!innerChild) return;

				const allocation = innerChild.get_allocation();

				if (
					x < allocation.x ||
					x > allocation.x + allocation.width ||
					y < allocation.y ||
					y > allocation.y + allocation.height
				) {
					if (!props.onClickedOutside) {
						self.close();
						return;
					}

					props.onClickedOutside?.(self);
				}
			}
		},
		onKeyPressEvent: (self, event: Gdk.Event) => {
			if (event.get_keyval()[1] === Gdk.KEY_Escape) {
				self.close();
				return;
			}

			props.onKeyPressEvent?.(self, event);
		},
		child: new Widget.Box({
			expand: props.expand ?? false,
			halign: props.halign,
			valign: props.valign,
			hexpand: true,
			css: `box {
                margin-left: ${props.marginLeft ?? 0}px;
                margin-right: ${props.marginRight ?? 0}px;
                margin-top: ${props.marginTop ?? 0}px;
                margin-bottom: ${props.marginBottom ?? 0}px;
            }`,

			child: new Widget.Box({
				onButtonPressEvent: props.onButtonPressEvent ?? (() => true),
				widthRequest: props.widthRequest,
				heightRequest: props.heightRequest,
				child: props.child,
			} as Widget.BoxProps),
		} as Widget.BoxProps),
	} as Widget.WindowProps);
}
