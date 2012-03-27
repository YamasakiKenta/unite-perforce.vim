
function! unite#sources#p4_have#define()
	return s:source
endfunction

"p4 have 
let s:source = {
			\ 'name' : 'p4_have',
			\ 'description' : '���L����t�@�C��',
			\ }

function! s:get_candidates_from_pfhave(datas) "{{{
	let candidates = map( a:datas, "{
				\ 'word' : perforce#get_depot_from_have(v:val),
				\ 'kind' : 'k_depot',
				\ 'action__depot' : perforce#get_depot_from_have(v:val),
				\ }")
	return candidates
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	"********************************************************************************
	"@param[in]	args		perforce���猟������t�@�C����
	"********************************************************************************
	let datas = split(system('p4 have '.join(a:args)),'\n')
	return <SID>get_candidates_from_pfhave(datas)
endfunction "}}}
