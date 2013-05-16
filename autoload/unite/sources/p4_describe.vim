let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_describe#define()
	return s:source_describe
endfunction

function! s:get_file_source_describe(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let data_d = {
		\ 'path'   : '',
		\ 'depot'  : '',
		\ 'revnum' : '',
		\ }
	for out in outs
		let num = perforce#get#lnum#from_diff_describe(out, num.lnum, num.snum)
		let lnum = num.lnum
		let data_d = perforce#get#path#from_diff(data_d, out)
		let candidates += [{
					\ 'word'           : lnum.' : '.out,
					\ 'kind'           : 'k_p4_filelog',
					\ 'action__line'   : lnum,
					\ 'action__depot'  : data_d.depot,
					\ 'action__revnum' : data_d.revnum,
					\ 'action__text'   : substitute(out,'^[<>] ','',''),
					\ }]
	endfor
	return candidates
endfunction
"}}}

let s:source_describe = {
			\ 'name' : 'p4_describe',
			\ 'description' : 'サブミット済みのチェンジリストの差分を表示',
			\ }
function! s:source_describe.gather_candidates(args, context) "{{{
	let chnums = a:args
	let outs = perforce#cmd#base('describe','',join(chnums)).outs
	return s:get_file_source_describe(outs) 
endfunction
"}}}

if 0
	call unite#define_source(s:source_describe)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

