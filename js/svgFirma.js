document.addEventListener('DOMContentLoaded', function () {
  // --- config: apuntar al svg correcto (solicitante) ---
  const wrapper = document.getElementById('signature-wrapper-solicitante');
  const svg = document.getElementById('signature-svg-solicitante');
  const clearBtn = document.getElementById('clearBtn-solicitante');
  const hiddenFirma = document.getElementById('firma_svg');
  const form = document.forms['permisoForm'];

  // viewBox coords
  const SVG_W = 1000, SVG_H = 200;
  svg.setAttribute('viewBox', `0 0 ${SVG_W} ${SVG_H}`);

  let drawing = false;
  let currentPoints = [];
  const strokes = [];

  function getSvgPoint(evt){
    const rect = wrapper.getBoundingClientRect();
    const clientX = (evt.clientX === undefined) ? (evt.touches && evt.touches[0].clientX) : evt.clientX;
    const clientY = (evt.clientY === undefined) ? (evt.touches && evt.touches[0].clientY) : evt.clientY;
    const x = ((clientX - rect.left) / rect.width) * SVG_W;
    const y = ((clientY - rect.top) / rect.height) * SVG_H;
    return { x: Math.max(0, Math.min(SVG_W, x)), y: Math.max(0, Math.min(SVG_H, y)) };
  }

  function updatePathElement(pathElem, pts){
    if(pts.length === 0) return;
    let d = `M ${pts[0].x.toFixed(2)} ${pts[0].y.toFixed(2)}`;
    for(let i=1;i<pts.length;i++){
      d += ` L ${pts[i].x.toFixed(2)} ${pts[i].y.toFixed(2)}`;
    }
    pathElem.setAttribute('d', d);
  }

  function startStroke(evt){
    evt.preventDefault();
    drawing = true;
    currentPoints = [];
    const p = getSvgPoint(evt);
    currentPoints.push(p);
    const path = document.createElementNS('http://www.w3.org/2000/svg','path');
    path.setAttribute('fill','none');
    path.setAttribute('stroke-width','3');
    path.setAttribute('stroke-linecap','round');
    path.setAttribute('stroke-linejoin','round');
    path.setAttribute('stroke','black');
    path.dataset.temp = '1';
    svg.appendChild(path);
    updatePathElement(path, currentPoints);
    if(evt.pointerId) wrapper.setPointerCapture(evt.pointerId);
  }
  function moveStroke(evt){
    if(!drawing) return;
    const p = getSvgPoint(evt);
    const last = currentPoints[currentPoints.length-1] || {x:0,y:0};
    if(Math.hypot(p.x-last.x, p.y-last.y) < 1) return;
    currentPoints.push(p);
    const path = svg.querySelector('path[data-temp="1"]');
    if(path) updatePathElement(path, currentPoints);
  }
  function endStroke(evt){
    if(!drawing) return;
    drawing = false;
    const path = svg.querySelector('path[data-temp="1"]');
    if(path){
      path.removeAttribute('data-temp');
      strokes.push(path.getAttribute('d'));
    }
    currentPoints = [];
    try{ if(evt.pointerId) wrapper.releasePointerCapture(evt.pointerId); }catch(e){}
  }

  // exporta todo como SVG string
  function exportSVG(){
    if(strokes.length === 0) return '';
    const header = `<svg xmlns="http://www.w3.org/2000/svg" width="${SVG_W}" height="${SVG_H}" viewBox="0 0 ${SVG_W} ${SVG_H}">`;
    const paths = strokes.map(d => `<path d="${d}" fill="none" stroke="black" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>`).join('');
    return header + paths + `</svg>`;
  }

  function clearSignature(){
    strokes.length = 0;
    while (svg.firstChild) svg.removeChild(svg.firstChild);
    hiddenFirma.value = '';
  }

  // eventos pointer (compatibles mouse/touch/stylus)
  wrapper.addEventListener('pointerdown', startStroke);
  wrapper.addEventListener('pointermove', moveStroke);
  wrapper.addEventListener('pointerup', endStroke);
  wrapper.addEventListener('pointercancel', endStroke);
  wrapper.addEventListener('pointerleave', endStroke);
  // soporte touch como fallback (por si el navegador no tiene pointer)
  wrapper.addEventListener('touchstart', startStroke, {passive:false});
  wrapper.addEventListener('touchmove', moveStroke, {passive:false});
  wrapper.addEventListener('touchend', endStroke);

  clearBtn.addEventListener('click', clearSignature);

  // Al enviar el formulario: serializar SVG y colocarlo en input oculto
  form.addEventListener('submit', function(e){
    // primero las validaciones que ya tenías (tipo_solicitud/tipo_permiso)
    const tipoSolicitudChecked = document.querySelectorAll('input[name="solicitud"]:checked').length > 0;
    const tipoPermisoChecked = document.querySelectorAll('input[name="tipo_permiso"]:checked').length > 0;
    if (!tipoSolicitudChecked) { alert('Por favor seleccione un tipo de solicitud para la solicitud.'); e.preventDefault(); return false; }
    if (!tipoPermisoChecked) { alert('Por favor seleccione al menos un tipo de permiso.'); e.preventDefault(); return false; }

    // serializamos SVG; si está vacío, prevenimos envío (si quieres obligarlo)
    const svgStr = exportSVG();
    if (!svgStr || svgStr.length === 0) {
      alert('Por favor firma en el recuadro antes de enviar la solicitud.');
      e.preventDefault();
      return false;
    }

    // ponemos el valor en el campo oculto
    hiddenFirma.value = svgStr;
    // permitir que el formulario se envíe
  });

});
