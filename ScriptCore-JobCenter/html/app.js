const app = document.getElementById('app');
const jobsContainer = document.getElementById('jobs');
const closeBtn = document.getElementById('closeBtn');
const searchInput = document.getElementById('searchInput');
const title = document.getElementById('title');
const subtitle = document.getElementById('subtitle');

let jobs = [];
const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'ScriptCore-JobCenter';

function postNui(event, data = {}) {
    fetch(`https://${resourceName}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).catch(() => {});
}

function escapeHtml(value) {
    return String(value ?? '').replace(/[&<>'"]/g, (char) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        "'": '&#039;',
        '"': '&quot;'
    }[char]));
}

function iconClass(icon) {
    if (!icon) return 'fa-solid fa-briefcase';
    return icon.includes('fa-') ? `fa-solid ${icon}` : 'fa-solid fa-briefcase';
}

function renderJobs() {
    const query = searchInput.value.toLowerCase().trim();
    const filteredJobs = jobs.filter((job) => `${job.label || ''} ${job.job || ''}`.toLowerCase().includes(query));

    jobsContainer.innerHTML = '';

    if (!filteredJobs.length) {
        jobsContainer.innerHTML = '<div class="empty">Ingen jobs fundet</div>';
        return;
    }

    filteredJobs.forEach((job) => {
        const card = document.createElement('article');
        card.className = 'job-card';
        card.innerHTML = `
            <div class="job-icon"><i class="${iconClass(job.icon)}"></i></div>
            <div class="job-info">
                <h2>${escapeHtml(job.label || job.job)}</h2>
                <span>${escapeHtml(job.job)}</span>
            </div>
            <button class="choose-btn">Vælg</button>
        `;

        card.querySelector('.choose-btn').addEventListener('click', () => {
            postNui('selectJob', { job: job.job });
        });

        jobsContainer.appendChild(card);
    });
}

function openUi(data) {
    jobs = Array.isArray(data.jobs) ? data.jobs : [];
    title.textContent = data.title || 'Jobcenter';
    subtitle.textContent = data.subtitle || 'Vælg et job';
    searchInput.value = '';
    app.classList.remove('hidden');
    renderJobs();
    setTimeout(() => searchInput.focus(), 50);
}

function closeUi() {
    app.classList.add('hidden');
}

window.addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.action === 'open') openUi(data);
    if (data.action === 'close') closeUi();
});

closeBtn.addEventListener('click', () => postNui('close'));
searchInput.addEventListener('input', renderJobs);

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') postNui('close');
});
