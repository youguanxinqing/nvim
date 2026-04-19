vim.filetype.add({
  pattern = {
    [".*%.Dockerfile"] = "dockerfile",
    ["Dockerfile%..*"] = "dockerfile",
  },
})
