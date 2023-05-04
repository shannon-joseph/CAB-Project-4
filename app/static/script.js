/**
 * Global variable definitions
 * view: stores the view type from localStorage to be set
 * svg: stores the d3 svg object that contains all map information for use across functions
 * currCounty, currMun: store parameters passed to loadMap for ease of use in other functions
 */
let view = localStorage.getItem('njmap_view') || 'ev';
let svg;
let currCounty;
let currMun;

// Sets inital view button and adds listeners to all buttons for click events
document.querySelector(`.stat-btn#${view}`).classList.add('active');
document.querySelectorAll('.stat-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
        setView(btn.id);
        document
            .querySelectorAll('.stat-btn')
            .forEach((btn) => btn.classList.remove('active'));
        btn.classList.add('active');
    });
});

/**
 * Loads the an svg tag with the requested map from geojson data using d3.js
 * @param {string} county - The county to be loaded, or empty string for entire state
 * @param {string} mun - The municipality selected for denotation in the svg, or empty string from only county
 */
const loadMap = (county, mun) => {
    currCounty = county;
    currMun = mun;

    // d3 loads in proper geojson file in preparation for svg creation
    d3.json(
        !county
            ? '/geojson/counties.geojson'
            : `/geojson/counties/${county
                  .toLowerCase()
                  .split(' ')
                  .join('_')}.geojson`
    ).then(function (json) {
        // Basic d3 geojson parameters for visualization
        let width = 600,
            height = 600;
        let projection = d3.geoMercator();
        let geoGenerator = d3.geoPath().projection(projection);

        projection.fitSize([width, height], json);
        const sel = document.querySelector('#svganchor');
        sel.innerHTML = '';
        svg = d3
            .select('#svganchor')
            .append('svg')
            .attr('viewBox', `0 0 ${width} ${height}`);

        // Creates paths for each feature in geojson
        svg.selectAll('path')
            .data(json.features)
            .enter()
            .append('path')
            .attr('d', geoGenerator)
            .attr('fill', 'white')
            .attr('stroke', '#000')
            .attr('cursor', 'pointer')
            .on('mouseover', function (e) {
                // Mouse listeners (mouseover, mouseout, mousemove) for tooltip placement
                d3.select('#tooltip')
                    .style('opacity', 1)
                    .text(e.properties.NAME + (!county ? ' County' : ''))
                    .style('left', d3.event.pageX + 'px')
                    .style('top', d3.event.pageY + 'px');
            })
            .on('mouseout', function () {
                d3.select('#tooltip').style('opacity', 0);
            })
            .on('mousemove', () => {
                d3.select('#tooltip')
                    .style('left', d3.event.pageX + 'px')
                    .style('top', d3.event.pageY + 'px');
            })
            .on('click', (e) => {
                // Click listener redirects page as appropriate
                if (!county) {
                    window.location = `/county/${e.properties.NAME}`;
                    return;
                }
                d3.select('#tooltip').style('opacity', 0);
                window.location = `/mun/${county}/${e.properties.GNIS_NAME}`;
            });
        setView();
    });
};

/**
 * Called on selection of any view layer to color paths accordingly by metric
 * @param {string} viewType - Specified view layer to set; either 'ev', 'ghgTotal', or 'ghgVehicles'
 */
const setView = (viewType) => {
    if (viewType) {
        view = viewType;
        localStorage.setItem('njmap_view', viewType);
    }

    // Switch statement to determine color based on viewType
    let interpolator;
    switch (view) {
        case 'ev':
            interpolator = d3.interpolateBlues;
            break;
        case 'ghgTotal':
            interpolator = d3.interpolateGreens;
            break;
        case 'ghgVehicles':
            interpolator = d3.interpolatePurples;
            break;
    }

    // Sets color for each path based on feature information in geojson
    svg.selectAll('path').attr('fill', (e) => {
        // If a county map is shown, uses nameToSelect to convert a town's GNIS_NAME into the name in the backend
        // Sets colors based on the appropriate town names, array, and interpolator
        if (currCounty) {
            const nameParts = e.properties.GNIS_NAME.split(' ');
            const nameToSelect =
                nameParts.length > 1
                    ? nameParts.slice(2).join(' ') +
                      ' ' +
                      nameParts[0].toLowerCase()
                    : e.properties.GNIS_NAME;
            if (currMun === e.properties.GNIS_NAME) return 'red';
            if (window[view + 'Norm'][nameToSelect]) {
                return interpolator(window[view + 'Norm'][nameToSelect]);
            }
        }

        // Otherwise, a county's name can simply be used in the proper array for the interpolated value
        if (window[view + 'Norm'][e.properties.NAME])
            return interpolator(window[view + 'Norm'][e.properties.NAME]);
        return 'white';
    });
};
