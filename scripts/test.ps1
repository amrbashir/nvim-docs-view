#!/usr/bin/env pwsh
# launch nvim w/ plugin loaded, no plugin manager
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
nvim --clean -u scripts/minimal-init.lua $args
