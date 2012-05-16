"action - debug_print "{{{
let s:action = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'debug print',
			\ }
call unite#custom_action('common', 'debug_print', s:action)
function! s:action.func(candidates) "{{{
	echo a:candidates
	call input("")
endfunction "}}}
unlet s:action "}}}
