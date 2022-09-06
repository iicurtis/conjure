local _2afile_2a = "fnl/conjure/client/python/stdio.fnl"
local _2amodule_name_2a = "conjure.client.python.stdio"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, extract, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
config.merge({client = {python = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "python3 -iq", prompt_pattern = ">>> "}}}})
local cfg = config["get-in-fn"]({"client", "python", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".py"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "# "
_2amodule_2a["comment-prefix"] = comment_prefix
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function prep_code(s)
  return (s .. "\n\n")
end
_2amodule_locals_2a["prep-code"] = prep_code
local function unbatch(msgs)
  local function _3_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_3_, msgs))
end
_2amodule_2a["unbatch"] = unbatch
local function format_msg(msg)
  local function _4_(_241)
    return ("" ~= _241)
  end
  return a.filter(_4_, str.split(msg, "\n"))
end
_2amodule_2a["format-msg"] = format_msg
local function is_dots_3f(s)
  return (string.sub(s, 1, 3) == "...")
end
_2amodule_locals_2a["is-dots?"] = is_dots_3f
local function get_console_output_msgs(msgs)
  local function _5_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  local function _6_(_241)
    return not is_dots_3f(_241)
  end
  return a.map(_5_, a.filter(_6_, a.butlast(msgs)))
end
_2amodule_locals_2a["get-console-output-msgs"] = get_console_output_msgs
local function get_result(msgs)
  local result = a.last(msgs)
  if (a["nil?"](result) or is_dots_3f(result)) then
    return nil
  else
    return result
  end
end
_2amodule_locals_2a["get-result"] = get_result
local function log_repl_output(msgs)
  local msgs0 = format_msg(unbatch(msgs))
  local console_output_msgs = get_console_output_msgs(msgs0)
  local cmd_result = get_result(msgs0)
  if not a["empty?"](console_output_msgs) then
    log.append(console_output_msgs)
  else
  end
  if cmd_result then
    return log.append({cmd_result})
  else
    return nil
  end
end
_2amodule_locals_2a["log-repl-output"] = log_repl_output
local function eval_str(opts)
  local function _10_(repl)
    local function _11_(msgs)
      log_repl_output(msgs)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _11_, {["batch?"] = true})
  end
  return with_repl_or_warn(_10_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
_2amodule_2a["stop"] = stop
local update_python_displayhook = ("import sys\n" .. "def format_output(val):\n" .. "    print(repr(val))\n\n" .. "sys.displayhook = format_output\n")
do end (_2amodule_2a)["update-python-displayhook"] = update_python_displayhook
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _15_()
      local function _16_(repl)
        return repl.send(prep_code(update_python_displayhook), log_repl_output, {["batch?"] = true})
      end
      return display_repl_status("started", with_repl_or_warn(_16_))
    end
    local function _17_(err)
      return display_repl_status(err)
    end
    local function _18_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(comment_prefix .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(comment_prefix .. "process exited with signal " .. signal)})
      else
      end
      return stop()
    end
    local function _21_(msg)
      return log.dbg(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _15_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
_2amodule_2a["start"] = start
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
local function interrupt()
  local function _23_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_23_)
end
_2amodule_2a["interrupt"] = interrupt
local function on_filetype()
  mapping.buf("n", "PythonStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
  mapping.buf("n", "PythonStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
  return mapping.buf("n", "PythonInterrupt", cfg({"mapping", "interrupt"}), _2amodule_name_2a, "interrupt")
end
_2amodule_2a["on-filetype"] = on_filetype
return _2amodule_2a