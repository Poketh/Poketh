let sx = 5;
let sy = 4;

let raw = [15032114,15032114,0,0,0,16707022,8411978,15032114,15032114,0,16227374,11569738,8411978,0,0,0,15582605,16707022,0,0];

let hexdata = raw.map(d => {
	return [(0xFF0000 & d) >> 16, (0x00FF00 & d) >> 8, 0x0000FF & d, d === 0 ? 0 : 255]
})

let rdata = [].concat(...hexdata).slice()

let canvas = document.createElement( 'canvas' );
	canvas.width = sx;
	canvas.height = sy;
	
document.body.appendChild( canvas );

let context = canvas.getContext( '2d' );

let imageData = context.getImageData ( 0, 0, sx, sy );
let data = imageData.data;

for(let i = 0; i < rdata.length; i++){
	data[i] = rdata[i];
}

context.putImageData( imageData, 0, 0 );
