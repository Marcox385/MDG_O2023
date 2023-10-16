// const htmlToImage = require('html-to-image');
// const download = require('downloadjs');

// function downloadMap() {
//     htmlToImage.toPng(document.getElementById('map-container'))
//     .then(function (dataUrl) {
//         download(dataUrl, 'k1-coloring.png');
//     });
// }

function loadRegions() {
    const mapContainer = document.getElementById('map-container');
    let imgs = ['ABR.png',  'CLB.png',  'EML.png',  'LAZ.png',  'LOM.png',  'MRC.png',  'PMT.png',  'SDG.png',  'TSC.png',  'VLL.png',
        'BSL.png',  'CMP.png',  'FRL.png',  'LIG.png',  'MOL.png',  'PGL.png',  'SCL.png',  'TRT.png',  'UMB.png',  'VNT.png'];

    let res = fetch('http://localhost:3200/getColors')
        .then(res => res.json())
        .then((out) => {
            for (let i = 0; i < imgs.length; i++) {
                let color = out[imgs[i].split('.')[0]].color;

                let imgHolder = document.createElement('img');
                imgHolder.src = 'view/assets/regions/' + imgs[i];
                imgHolder.style.position = 'absolute';
                imgHolder.style.zIndex = `${i + 1}`;
                imgHolder.style.filter = `brightness(75%) sepia(100) saturate(100) hue-rotate(${75*color}deg)`
                let newImg = mapContainer.appendChild(imgHolder);
                console.log(newImg);
            }
    }).catch(err => console.error(err));
}
