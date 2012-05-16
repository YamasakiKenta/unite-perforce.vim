
function! unite#sources#p4_have#define()
	return [s:souce_p4have, s:source_p4_have_async]
endfunction

let g:cache = {}

"p4 have 
let s:source = {
			\ 'name' : 'p4_have',
			\ 'description' : '���L����t�@�C��',
			\ }
"********************************************************************************
"@param[in]	args		perforce���猟������t�@�C����
"********************************************************************************
function! s:source.gather_candidates(args, context) "{{{
	return <SID>get_datas_from_p4_have(join(a:args)).candidates
endfunction "}}}
let s:souce_p4have = s:source

let s:source = {
			\ 'name' : 'p4_have_async',
			\ 'description' : '���L����t�@�C�� ( file ����擾���� ) ',
			\ }
"********************************************************************************
"@param[in]	args		perforce���猟������t�@�C����
"********************************************************************************
function! s:source.gather_candidates(args, context) "{{{

	if 0 
		let kind = join(a:args)
		let datas = split(system('p4 have '.kind),'\n')

	else
		let kind = $PFHAVE
		let datas = <SID>get_datas(kind)

	endif

	let a:context.source__p4have = {
				\ 'datas' : datas,
				\ }


	return datas.candidates
endfunction "}}}
function! s:source.async_gather_candidates(args, context) "{{{

	let time = reltime()
	let datas = a:context.source__p4have.datas
	let len   = a:context.source__p4have.datas.line_max

	let rtns = []

	while str2float(reltimestr(reltime(time))) < 0.05
				\ && len(a:context.source__p4have.datas.lines) > 0
		let data = [remove(a:context.source__p4have.datas.lines,0)]
		let rtns += <SID>get_candidates_from_pfhave(data)
	endwhile
	let nowlen = len(a:context.source__p4have.datas.lines)

	call unite#clear_message()
	call unite#print_message(printf("%s / %s",len-nowlen, len))

	if len(a:context.source__p4have.datas) == 0 
        let a:context.is_async = 0
	call unite#print_message(printf("%s / %s - complete",len-nowlen, len))
	endif

	let a:context.source__p4have.datas.candidates += rtns

	return rtns
endfunction "}}}
let s:source_p4_have_async = s:source
  

"================================================================================
" subrutine
"================================================================================
function! s:get_datas(str) "{{{

	if !has_key(g:cache, a:str)
		let g:cache[a:str] = {
			\ 'lines' : readfile(a:str),
			\ 'candidates' :[],
			\ } 
		let g:cache[a:str].line_max = len(g:cache[a:str].lines)
	endif

	return g:cache[a:str]
endfunction "}}}
function! s:get_datas_from_p4_have(str) "{{{

	" �󔒂̏ꍇ�́A�X�y�[�X���g�p����
	let str = a:str
	if str == ''
		let str = ' '
	endif 

	if !has_key(g:cache, str)
		echo 'loading...'
		let datas = split(system('p4 have '.str),'\n')
		let g:cache[str] = {
					\ 'lines' : [],
					\ 'candidates' : <SID>get_candidates_from_pfhave(datas),
					\ }
		echo 'finish !!'
	else
		echo 'cache load!'
	endif

	return g:cache[str]
endfunction "}}}
function! s:get_candidates_from_pfhave(datas) "{{{
	let candidates = map( a:datas, "{
				\ 'word' : perforce#get_depot_from_have(v:val),
				\ 'kind' : 'k_depot',
				\ 'action__depot' : perforce#get_depot_from_have(v:val),
				\ }")
	return candidates
endfunction "}}}
