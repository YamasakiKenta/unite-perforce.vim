let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_describe#define()
	return s:source_describe
endfunction

let s:source_describe = {
			\ 'name' : 'p4_describe',
			\ 'description' : 'サブミット済みのチェンジリストの差分を表示',
			\ }
function! s:source_describe.gather_candidates(args, context) "{{{
	let chnums = a:args
	let outs = perforce#cmd#base('describe','',join(chnums)).outs
	return perforce#get#file#source_describe(outs) 
endfunction
"}}}

if 1
	call unite#define_source(s:source_describe)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

