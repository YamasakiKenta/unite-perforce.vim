
function! unite#sources#p4_have#define()
	return s:source
endfunction

let g:cache = { 'default' : []}

"p4 have 
let s:source = {
			\ 'name' : 'p4_have',
			\ 'description' : '所有するファイル',
			\ }

function! s:get_candidates_from_pfhave(datas) "{{{
	if 1
		let candidates = map( a:datas, "{
					\ 'word' : perforce#get_depot_from_have(v:val),
					\ 'kind' : 'k_depot',
					\ 'action__depot' : perforce#get_depot_from_have(v:val),
					\ }")
	elseif 0
		let candidates = map( a:datas, "{
					\ 'word' : v:val,
					\ 'kind' : 'k_depot',
					\ 'action__depot' : v:val,
					\ }")
	elseif 0
		let candidates = [{
					\ 'word' : 'v:val',
					\ 'kind' : 'k_depot',
					\ 'action__depot' : 'v:val',
					\ }]
	endif
	return candidates
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	"********************************************************************************
	"@param[in]	args		perforceから検索するファイル名
	"********************************************************************************
	let datas = split(system('p4 have '.join(a:args)),'\n')
	return <SID>get_candidates_from_pfhave(datas)
endfunction "}}}

let s:source = {
			\ 'name' : 'p4_have',
			\ 'description' : '所有するファイル ( file から取得する ) ',
			\ 'hooks' : {}
			\ }

function! s:source.hooks.on_init(args, context)
	let a:context.source__test = 1
endfunction
function! s:source.gather_candidates(args, context) 
	"********************************************************************************
	"@param[in]	args		perforceから検索するファイル名
	"********************************************************************************
	if 0 
		let datas = split(system('p4 have '.join(a:args)),'\n')
	else
		let datas = readfile($PFHAVE)
		let datas = <SID>get_datas($PFHAVE)
	endif

	let a:context.source__p4have = {
				\ 'datas' : datas,
				\ 'len' : len(datas),
				\ }

	let rtns = g:cache.default
	if 0
		return  [{
					\ 'word' : 'v:val',
					\ 'kind' : 'k_depot',
					\ 'action__depot' : 'v:val',
					\ }]
	endif
	return rtns
endfunction 
function! s:get_datas(path)
	if !has_key(g:cache, a:path)
		let g:cache[a:path] = readfile(a:path)
	endif
	return g:cache[a:path]
endfunction
function! s:source.async_gather_candidates(args, context)

	let time = reltime()
	let p4have = a:context.source__p4have
	let datas = a:context.source__p4have.datas
	let len = a:context.source__p4have.len

	let rtns = []

	while str2float(reltimestr(reltime(time))) < 0.05
				\ && len(a:context.source__p4have.datas) > 0
		let data = [remove(a:context.source__p4have.datas,0)]
		let rtns += <SID>get_candidates_from_pfhave(data)
	endwhile
	let nowlen = len(a:context.source__p4have.datas)

	call unite#clear_message()
	call unite#print_message(printf("%s  / %s",nowlen, len))

	if len(a:context.source__p4have.datas) == 0 
        let a:context.is_async = 0
	call unite#print_message(printf("%s  / %s - complete",nowlen, len))
	endif

	let g:cache.default += rtns

	return rtns
endfunction
