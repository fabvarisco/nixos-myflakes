function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('clock').textContent = `${hours}:${minutes}`;
}

function updateDate() {
    const now = new Date();
    const options = {
        weekday: 'long',
        day: 'numeric',
        month: 'long'
    };
    document.getElementById('date').textContent = now.toLocaleDateString('pt-BR', options);
}

updateClock();
updateDate();
setInterval(updateClock, 1000);
setInterval(updateDate, 60000);
