-- Autocommands
-- use function for smaller scope
local ftypeopts = {
    defaults = {
        tabstop = 2,
        shiftwidth = 2,
    },
    python = {
        tabstop = 4,
        shiftwidth = 4,
    },
    lua = {
        tabstop = 4,
        shiftwidth = 4,
    },
    vim = {
        tabstop = 4,
        shiftwidth = 4,
    },
    xml = {
        tabstop = 4,
        shiftwidth = 4,
    },
    java = {
        tabstop = 4,
        shiftwidth = 4,
    },
    help = {
        expandtab = false,
        modeline = true,
        tabstop = 8,
        shiftwidth = 8,
    },
    vimdoc = {
        expandtab = false,
        modeline = true,
        tabstop = 8,
        shiftwidth = 8,
    },
}

local bufopts = {
    {
        pattern = { "*.gltf", },
        options = { filetype = "json", }
    },
}


function LoadOpts(opts, buf)
    for key, value in pairs(opts) do
        vim.bo[buf][key] = value
    end
end

function LoadFiletypeOpts(opts)
    local bufferopts = ftypeopts[vim.bo[opts.buf].filetype] or ftypeopts.defaults
    LoadOpts(bufferopts, opts.buf)
end
function LoadBufferOptAutocmd(augroup)
    for _, bufoptions in ipairs(bufopts) do
        vim.api.nvim_create_autocmd(
            { "BufNewFile", "BufRead" },
            {
                group = augroup,
                pattern = bufoptions.pattern,
                callback = function(options)
                    LoadOpts(bufoptions.options, options.buf)
                end,
            }
        )
    end
end

local function load()
    local augroup = vim.api.nvim_create_augroup("openBufOpts", {})
    vim.api.nvim_create_autocmd({ "FileType" }, {
        group = augroup,
        callback = LoadFiletypeOpts,
    })
    vim.api.nvim_create_autocmd({ "TermOpen" }, {
        group = augroup,
        callback = function()
            vim.keymap.set(
                't', '<c-e>',
                vim.cmd.stopinsert,
                { buffer = 0, }
            )
            vim.cmd.setlocal 'nornu nonumber'
            vim.api.nvim_buf_set_name(0, string.match(
                vim.api.nvim_buf_get_name(0),
                '//[0-9]*:%S+'
            ))
            vim.cmd 'startinsert'
        end,
    });
    vim.api.nvim_create_autocmd({ "TermClose" }, {
        group = augroup,
        command = 'bd!',
    })
    vim.api.nvim_create_autocmd({ "DirChanged" }, {
        group = augroup,
        callback = function()
            local wsname = require'nvimcord.workspace'.get_name()
            require'nvimcord.discord'.config.workspace_name = wsname
        end
    })
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = augroup,
        command = 'NvimcordUpdate',
    })
    vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
        group = augroup,
        callback = require'config.functions'.reloadCtags,
    });
    LoadBufferOptAutocmd(augroup)
end

return {
    load = load,
}

