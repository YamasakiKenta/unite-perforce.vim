let s:save_cpo = &cpo
set cpo&vim


let action = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function action.func(candidates)
	return pf_action#sub_action_log(a:candidates, 'add')
endfunction
call unite#custom_action('jump_list' , 'p4_add' , action)
call unite#custom_action('file'      , 'p4_add' , action)


let action = {
				\ 'is_selectable' : 1, 
				\ 'description'   : '',
				\ }
function action.func(candidates)
	return pf_action#sub_action_log(a:candidates, 'edit')
endfunction
call unite#custom_action('jump_list' , 'p4_edit' , action)
call unite#custom_action('file'      , 'p4_edit' , action)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
