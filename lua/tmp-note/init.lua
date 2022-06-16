local api = vim.api
local timestamp_format = '%Y-%m-%d'
local win, buf
local noteFile = 'note.md'


local function setup(opts)
	opts = opts or {}
	noteFile = opts.options.note
    vim.cmd(":command! TmpNote lua require'tmp-note'.note()")
end

local function current_date()
	return os.date(timestamp_format)
end

local function close_window()
        vim.cmd(':w')
        api.nvim_win_close(win, true)
end

local function note()
        local width = api.nvim_get_option('columns') / 3
        local height = api.nvim_get_option('lines') / 3
        local options = {
                relative='win', width=width, height=height, bufpos = {20,20}
        }
        local buf = api.nvim_create_buf(false, true)
        win = api.nvim_open_win(buf, true, options)
        vim.cmd(":edit " .. noteFile)

        local noteHeader = "# note on "..current_date()
        local found_line = vim.fn.search(noteHeader)
        if found_line == 0 then
                vim.fn.append(vim.fn.line('$'), noteHeader)
        end

        vim.cmd(':$')

        api.nvim_create_autocmd({ 'BufWinLeave' }, {
                buffer = buf,
                callback = close_window
        })

        -- to delete
        local limitTime = os.time() - (30 * 3600)
        -- search({pattern} [, {flags} [, {stopline} [, {timeout} [, {skip}]]]])
        local sectionLineNum = 0
        while vim.fn.search('# note on', 'b', 1) > 0 do
                sectionLineNum = vim.fn.line('.')
                -- TODO limit 比較して、古い場合はここでbreakする
        end
        vim.cmd(":" .. sectionLineNum .. ",$write!")
        vim.cmd(":e")
end

return {
        setup = setup,
        note = note,
}
