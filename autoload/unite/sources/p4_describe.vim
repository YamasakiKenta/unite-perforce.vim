let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_describe#define()
	return s:source_describe
endfunction

function! s:get_file_source_describe(client, outs) "{{{
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
		call add(candidates, {
					\ 'word'           : printf("%5d : %s", lnum, out),
					\ 'action__line'   : lnum,
					\ 'action__depot'  : data_d.depot,
					\ 'action__revnum' : data_d.revnum,
					\ 'action__client' : a:client,
					\ 'action__text'   : substitute(out,'^[<>] ','',''),
					\ 'action__cmd'    : 'describe'
					\ })
	endfor
	return candidates
endfunction
"}}}

let s:source_describe = {
			\ 'name' : 'p4_describe',
			\ 'description' : 'サブミット済みのチェンジリストの差分を表示',
			\ 'default_kind' : 'k_p4_filelog',
			\ }
function! s:source_describe.gather_candidates(args, context) "{{{

	let data_ds = perforce#source#get_data_client('', 'chnum', a:args)

	let datas = []
	for data_d in data_ds
		let chnum            = data_d.chnum
		let use_port_clients = data_d.use_port_clients
		call extend(datas, perforce#cmd#clients(use_port_clients, 'p4 describe '.chnum))
	endfor

	let candidates = []
	for data in datas
		let outs = data.outs
		let client = data.client
		call extend(candidates, s:get_file_source_describe(client, outs))
	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_describe)

let &cpo = s:save_cpo
unlet s:save_cpo

