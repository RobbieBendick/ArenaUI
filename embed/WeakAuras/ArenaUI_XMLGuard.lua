-- Profiling.xml references mixin methods before Profiling.lua may run
-- (skipped when standalone WeakAuras is enabled, or if libs fail).
if not WeakAurasProfilingLineMixin then WeakAurasProfilingLineMixin = {} end
if not WeakAurasProfilingLineMixin.OnShow then WeakAurasProfilingLineMixin.OnShow = function() end end
if not WeakAurasProfilingMixin then WeakAurasProfilingMixin = {} end
if not WeakAurasProfilingMixin.OnShow then WeakAurasProfilingMixin.OnShow = function() end end
if not WeakAurasProfilingReportMixin then WeakAurasProfilingReportMixin = {} end
if not WeakAurasProfilingReportMixin.OnShow then WeakAurasProfilingReportMixin.OnShow = function() end end
