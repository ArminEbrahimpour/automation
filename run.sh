#!/bin/bash



read domain


subdomain_discovery(){

	echo "starting subfinder!"

	subfinder -d $domain --silent >> all_subdomains.txt &
	wait
	echo "httpx !!!!"
	cat all_subdomains.txt | httpx -silent >> live_subdomains.txt & 
	wait
}


hidden_files_discovery(){
	echo "fuzz faster u fool"
	ffuf -s -u https://$domain/FUZZ -w /home/t4yl4c1n3/H4/WordList/SecLists/Discovery/Web-Content/common.txt -mc 200,201,202,203,204,205,300,301,302,303,304,305,403 -o hidden_direcotry.txt -of json &
	
}

collect_all_links(){
	echo "start waybackurl"
	waybackurls $domain >> waybackurls.txt
}

port_scanning(){
	sub=$1
	echo "Scanning domain!"
	nmap -p 1-1000 -Pn $sub >> nmap_port_scanning.txt

}

collect_js_files(){

	echo "collecting js files path"

	file="./waybackurls.txt"

	cat $file | grep js >> js_files.txt

}

gf_output(){

	echo "using gf ;)"
	mkdir gf
	cat waybackurls.txt | gf idor >> ./gf/gf_idor.txt
	cat waybackurls.txt | gf img-traversal >> ./gf/gf_image-traversal.txt
	cat waybackurls.txt | gf intrestingEXT >> ./gf/gf_intrestingEXT.txt
	cat waybackurls.txt | gf intrestingparams >> ./gf/gf_intrestingparams.txt
#	cat waybackurls.txt | gf jsvar >> ./gf/gf_jsvar.txt
	cat waybackurls.txt | gf lfi >> ./gf/gf_lfi.txt
	cat waybackurls.txt | gf rce >> ./gf/gf_rce.txt
	cat waybackurls.txt | gf redirect >> ./gf/gf_redirect.txt
	cat waybackurls.txt | gf sqli >> ./gf/gf_sqli.txt
	cat waybackurls.txt | gf ssrf >> ./gf/gf_ssrf.txt
	cat waybackurls.txt | gf ssti >> ./gf/gf_ssti.txt
	cat waybackurls.txt | gf xss >> ./gf/gf_xss.txt

}

run_nuclei(){

	echo "nuclei go ::::)))))"
	mkdir nuclei
	nuclei -l js_files.txt >> ./nuclei/nuclei_js_files_&
	echo "nuclei just finished js filse "
	nuclei -l waybackurls.txt >> ./nuclei/nuclei_waybackurls.txt&
	echo "nuclei just finished waybackurls.txt file"
	nuclei -l ./gf/* >> ./nuclei/nuclei_gf.txt
	echo "nuclei finished it's job"
	

}


main(){

	subdomain_discovery

	hidden_files_discovery
	wait
	collect_all_links
	
	collect_js_files

	gf_output

	wait 
	run nuclei






	all_subdomains="./all_subdomains.txt"

	# put port scanning at the end of the proccess because it take so many time	

	while read -r sub
	do
		echo "scanning using nmap ${sub}"
		port_scanning "${sub}" &
		wait
	done < $all_subdomains
	wait
	echo "All scans completed"

	

}


main



