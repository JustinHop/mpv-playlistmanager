local utils = require("mp.utils")
local msg = require("mp.msg")
-- resolve url title and send it back to playlistmanager
mp.register_script_message("resolveurltitle", function(filename)
  local args = { 'youtube-dl', '--flat-playlist', '--no-playlist', '-sJ', filename }
  local res = utils.subprocess({ args = args })
  if res.status == 0 then
    local json, err = utils.parse_json(res.stdout)
    if not err then
      local is_playlist = json['_type'] and json['_type'] == 'playlist'
      local extractor = ''
      if json['extractor'] then
          extractor = ' @' .. json['extractor']
      end
      local uploader = ''
      if json['uploader'] then
        uploader = '[' .. json['uploader'] .. ']: '
      end
      local title = (is_playlist and '<playlist>: ' or '') .. uploader .. json['title'] .. extractor
      mp.commandv('script-message', 'playlistmanager', 'addurl', filename, title)
      msg.info("Added", filename, title)
    end
  end
end)
