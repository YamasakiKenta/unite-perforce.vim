function! unite#sources#p4_describe#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_describe',
			\ 'description' : 'サブミット済みのチェンジリストの差分を表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let chnums = a:args
	let outs = perforce#pfcmds('describe','',join(chnums))
	return perforce#get_diff_path(outs) 
endfunction "}}}
