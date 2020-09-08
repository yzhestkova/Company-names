use "${maindir}/patents.dta", replace
keep pdpass assignee_name /*pdpass is a unique assignee identifier*/
duplicates drop
gen assignee_cleaned = trim(itrim(lower(assignee_name))) 
replace assignee_cleaned = trim(itrim(ustrregexra(assignee_cleaned,"(^|\s)-($|\s)", " "))) 
replace assignee_cleaned = trim(itrim(ustrregexra(assignee_cleaned,"(^|\s)[XIV][XIV]?[XIV]?[XIV]?[XIV]?[XIV]?[XIV]?(,|$|\s)", " "))) 
replace assignee_cleaned = trim(itrim(ustrregexra(assignee_cleaned,"\s\d\d?\d?\d?\d?\d?\d?(,|$)", " "))) 
replace assignee_cleaned = trim(itrim(ustrregexra(assignee_cleaned,"^[0-9][0-9]?[0-9]?[0-9]?[0-9]?[0-9]?[0-9]?(,|$|\s)", " "))) 
stnd_specialchar assignee_cleaned, patpath("${maindir}/stata_extra/path/") /*directory of pattern files to clean punctuation*/
replace assignee_cleaned=stritrim(assignee_cleaned)
replace assignee_cleaned=strtrim(assignee_cleaned)
save temp.dta, replace

import delimited "${maindir}/universities.csv", encoding(UTF-8)clear
levels v1, local(universities)
foreach x of local `universities' {
replace uni_count=uni_count+1 if strpos(assignee_cleaned, "`x'") > 0
}
keep if uni_count>0
gen university=1
keep assignee_name pdpass university
duplicates drop
save "${maindir}/assignees_universities.dta", replace
