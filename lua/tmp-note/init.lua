local api = vim.api
local timestamp_format = '%Y-%m-%d'
local win
local config = {
        note = "note.md",
        keep_days = 30,
}

local function setup(opts)
    for key, value in pairs(opts) do
        config[key] = value
    end
end

local function current_date()
	return os.date(timestamp_format)
end

local function close_window()
        vim.cmd(':silent! :w')
        api.nvim_win_close(win, true)
end

local function note()
        local width = api.nvim_get_option("columns")
        local height = api.nvim_get_option("lines")
        local options = {
                relative='win',
                width= math.ceil(width * 0.7),
                height= math.ceil(height * 0.7),
                bufpos = {
                        math.ceil(height / 2),
                        math.ceil(width / 2),
                },
                border = 'single'
        }
        local buf = api.nvim_create_buf(false, true)
        win = api.nvim_open_win(buf, true, options)
        vim.cmd(":edit " .. config.note)

        local noteHeader = "# note on "..current_date()
        local found_line = vim.fn.search(noteHeader)
        if found_line == 0 then
                vim.fn.append(vim.fn.line('$'), noteHeader)
        end

        vim.fn.cursor(vim.fn.line('$'), 0)

        api.nvim_create_autocmd({ 'BufWinLeave' }, {
                buffer = buf,
                callback = close_window
        })

        -- to delete
        local limitTime = os.time() - (config.keep_days * 24 * 3600)
        local sectionLineNum, saveSectionLineNum = 0, 0

        saveSectionLineNum = vim.fn.line('.')
        local headerPattern = '# note on (%d+)-(%d+)-(%d+)'

        while vim.fn.search('# note on', 'b', 1) > 0 do
                sectionLineNum = vim.fn.line('.')
                local year, month, day = vim.fn.getline(sectionLineNum):match(headerPattern)
                local sectionTime = os.time({
                        year = year,
                        month = month,
                        day = day,
                })
                if limitTime > sectionTime then
                        break
                end
                saveSectionLineNum = sectionLineNum
        end
        vim.cmd(":silent! :" .. saveSectionLineNum .. ",$write!")
        vim.cmd(":e!")
        vim.opt.number = false
        vim.fn.cursor(vim.fn.line('$'), 0)
end

vim.cmd(":command! TmpNote lua require'tmp-note'.note()")

return {
        setup = setup,
        note = note,
}
