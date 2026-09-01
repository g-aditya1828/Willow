const file=document.getElementById("file"),choose=document.getElementById("choose"),upload=document.getElementById("upload"),result=document.getElementById("result"),again=document.getElementById("again"),filename=document.getElementById("filename");
choose.onclick=()=>file.click();
file.onchange=()=>{if(file.files[0])show(file.files[0])};
function show(f){filename.textContent=f.name.replace(/\.[^/.]+$/,"").replace(/[-_]+/g," ").replace(/\b\w/g,c=>c.toUpperCase())||"Your product";upload.classList.add("hidden");result.classList.remove("hidden");result.scrollIntoView({behavior:"smooth",block:"center"})}
again.onclick=()=>{file.value="";result.classList.add("hidden");upload.classList.remove("hidden")};
document.querySelectorAll('a[href^="#"]').forEach(a=>a.addEventListener("click",()=>window.scrollTo));
