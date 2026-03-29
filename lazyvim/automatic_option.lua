-- Example LazyVim config for automatic-verilog.
-- Put this file at:
--   ~/.config/nvim/lua/plugins/automatic_option.lua

return {
  {
    "HonkW93/automatic-verilog",
    init = function()
      -- Use filelist for cross-directory lookup.
      vim.g.atv_crossdir_mode = 1
      vim.g.atv_crossdir_backend = "auto"
      vim.g.atv_crossdir_flist_browse = 0

      -- Point to the main filelist. Environment variables are supported.
      vim.g.atv_crossdir_flist_file = vim.fn.expand("$PROJECT_ROOT/lazyvim/filelist.f")

      -- Common AutoInst preferences.
      vim.g.atv_autoinst_keep_chg = 1
      vim.g.atv_autoinst_incl_width = 1
      vim.g.atv_autoinst_incl_cmnt = 1
      vim.g.atv_autoinst_incl_ifdef = 1
      vim.g.atv_autoinst_add_dir = 0
      vim.g.atv_autoinst_add_dir_keep = 1

      -- Optional alignment preferences.
      vim.g.atv_autoinst_name_pos = 36
      vim.g.atv_autoinst_sym_pos = 72
      vim.g.atv_autodef_name_pos = 36
      vim.g.atv_autodef_sym_pos = 72
    end,
  },
}
