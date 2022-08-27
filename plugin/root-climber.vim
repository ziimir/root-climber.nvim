if exists('g:loaded_root_climber')
  finish
endif
let g:loaded_root_climber = 1

let g:root_climber#always_confirm = get(g:, 'root_climber#always_confirm', 0)
