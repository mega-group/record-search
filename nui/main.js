document.getElementById('searchBtn').addEventListener('click', function() {
    const value = document.getElementById('searchInput').value;
    if (value.trim() !== '') {
        fetch(`https://${GetParentResourceName()}/search`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query: value })
        });
    }
});

document.getElementById('closeBtn').addEventListener('click', function() {
    document.getElementById('mdt').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    });
});

window.addEventListener('message', function(event) {
    if (event.data.type === 'show') {
        document.getElementById('mdt').style.display = 'block';
    }
    if (event.data.type === 'results') {
        const resultsDiv = document.getElementById('results');
        resultsDiv.innerHTML = '';

        const groups = {
            Citation: [],
            Report: [],
            Arrest: [],
            "Vehicle Citation": []
        };

        event.data.results.forEach(function(result) {
            if (result.startsWith("Citation:")) groups.Citation.push(result);
            else if (result.startsWith("Report:")) groups.Report.push(result);
            else if (result.startsWith("Arrest:")) groups.Arrest.push(result);
            else if (result.startsWith("Vehicle Citation:")) groups["Vehicle Citation"].push(result);
        });

        Object.keys(groups).forEach(function(type) {
            if (groups[type].length > 0) {
                const section = document.createElement('div');
                section.innerHTML = `<h3>${type}s</h3>`;
                groups[type].forEach(function(item) {
                    const el = document.createElement('div');
                    el.textContent = item;
                    section.appendChild(el);
                });
                resultsDiv.appendChild(section);
            }
        });

        if (
            groups.Citation.length === 0 &&
            groups.Report.length === 0 &&
            groups.Arrest.length === 0 &&
            groups["Vehicle Citation"].length === 0
        ) {
            resultsDiv.textContent = 'No results found.';
        }
    }
});