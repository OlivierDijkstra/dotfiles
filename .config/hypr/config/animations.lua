-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Animations Configuration                 ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- https://wiki.hypr.land/Configuring/Animations/

hl.config({
    animations = {
        enabled = true,
    },
})

-- OS1-like easing curves: calm, soft, and deliberate
hl.curve("os1Ease", { type = "bezier", points = { { 0.32, 0.05 }, { 0.22, 1 } } })
hl.curve("os1Flow", { type = "bezier", points = { { 0.22, 1 },    { 0.30, 1 } } })
hl.curve("os1Fade", { type = "bezier", points = { { 0.4,  0 },    { 0.2,  1 } } })

-- Window animations - smoother and brisk
hl.animation({ leaf = "windows",    enabled = true, speed = 2.3, bezier = "os1Ease" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.8, bezier = "os1Flow" })
hl.animation({ leaf = "border",     enabled = true, speed = 2.6, bezier = "os1Ease" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.7, bezier = "os1Fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.1, bezier = "os1Ease" })
