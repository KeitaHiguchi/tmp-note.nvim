local api = vim.api
local timestamp_format = '%Y-%m-%d'
local win, buf
local noteFile = 'note.md'


local function setup(opts)
	opts = opts or { 
            options = {
                    note = "note.md"
            }
    }
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
        local width = 80
        local height = 20
        local options = {
                relative='win',
                width=width,
                height=height,
                bufpos = {20,20},
                border = 'single'
        }
        local buf = api.nvim_create_buf(false, true)
        win = api.nvim_open_win(buf, true, options)
        vim.cmd(":edit " .. noteFile)

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
        local limitTime = os.time() - (30 * 24 * 3600)
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

return {
        setup = setup,
        note = note,
}
