"if exists("b:current_syntax")
"finish
"endif

syn match filePath /.*/
syn match fileName /^[^ ]* /

hi def link fileName  Label
hi def link filePath  Comment

let b:current_syntax = "ffind"
