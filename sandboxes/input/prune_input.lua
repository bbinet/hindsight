-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

--[[
Hindsight input log file pruner

Deletes the log files generated by the input plugins when all the analysis and
output plugins are done consumining them (within ticker_interval seconds).

*Example Hindsight Configuration*

.. code-block:: lua
filename = "prune_input.lua"
ticker_interval = 60

output_path   = "output" -- Path to the hindsight.cp file.
exit_on_stall = false -- When true, causes the plugin to stop/abort when the checkpoints are no longer advancing.
                      -- Use this option to allow hindsight_cli to exit when the inputs are finished. This plugin/option
                      -- is typically used when streaming a large data set from something like s3 i.e., running
                      -- a report.
--]]

require "io"
require "os"
require "string"
require "math"
local l = require "lpeg"
l.locale(l)

local output_path   = read_config("output_path") or error("output_path must be set")
local exit_on_stall = read_config("exit_on_stall")

local function get_min(t, i, o)
    if not t.min then t.min = math.huge end
    if i < t.min then
        t.min = i
        t.off = o
     end
    return t
end

local pair      = l.P"'" * l.Cg(l.digit^1/tonumber * ":" * l.C(l.digit^1)) * "'"
local ignore    = (l.P(1) - "\n")^0 * "\n"
local line      = l.P"_G['input->" * (l.P(1) - "'")^1 * "']" * l.space^0 * "=" * l.space^0 * pair * l.space^0 + ignore
local grammar   = l.Cf(l.Ct("") * line^1, get_min)
local min, off  = -1, -1

function process_message()
    local fh = io.open(output_path .. "/hindsight.cp")
    if not fh then return 0 end -- checkpoint file not available yet

    local s = fh:read("*a")
    fh:close()
    if s then
        local t = grammar:match(s)
        if t then
            if min == t.min and off == t.off then
                if exit_on_stall then
                    error("input has stopped")
                end
            else
                off = t.off
                if min ~= t.min then
                    min = t.min
                    for i = min - 1, 0, -1 do
                        local r = os.remove(string.format("%s/input/%d.log", output_path, i))
                        if not r then break end
                    end
                end
            end
        end
    end
    return 0
end
