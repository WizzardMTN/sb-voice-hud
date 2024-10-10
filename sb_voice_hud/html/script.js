const voiceHud = document.getElementById('voice-hud');
const voiceRange = document.getElementById('voice-range');
const voiceCircle = document.getElementById('voice-circle');
const voiceIcon = document.getElementById('voice-icon');
const micStatus = document.getElementById('mic-status');
const previewButton = document.getElementById('preview-button');
const muteButton = document.getElementById('mute-button');
const sprechenButton = document.getElementById('sprechen-button');
const micAnButton = document.getElementById('mic-an-button');

const ranges = [1, 2, 3, 5, 8, 15, 30];
let currentPreviewIndex = 0;

function updateVoiceRange(range) {
    voiceIcon.style.opacity = '0';
    voiceRange.style.opacity = '0';
    voiceRange.style.display = 'block';
    voiceRange.textContent = `${range} m`;
    
    setTimeout(() => {
        voiceIcon.style.opacity = '0';
        voiceRange.style.opacity = '1';
    }, 50);

    setTimeout(() => {
        voiceRange.style.opacity = '0';
        voiceIcon.style.opacity = '1';
    }, 1800);

    setTimeout(() => {
        voiceRange.style.display = 'none';
        voiceIcon.style.opacity = '1';
    }, 2000);
}

function updateVoiceCircle(range) {
    const index = ranges.indexOf(range);
    const fillPercentage = ((index + 1) / ranges.length) * 100;
    const colors = ['#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff'];

    voiceCircle.style.setProperty('--fill', `${fillPercentage}%`);
    voiceCircle.style.setProperty('--fill-color', colors[index]);
}

function previewNextRange() {
    currentPreviewIndex = (currentPreviewIndex + 1) % ranges.length;
    const range = ranges[currentPreviewIndex];
    updateVoiceCircle(range);
    voiceRange.textContent = `${range} m`;
}

function setVoiceIcon(iconPath) {
    voiceIcon.src = iconPath;
}

function updateStatus(element, label, enabled, disabled, talking = false) {
    let status = 'Off';
    let statusClass = 'status-off';

    if (!disabled) {
        if (enabled) {
            status = talking ? 'Talking' : 'On';
            statusClass = talking ? 'status-talking' : 'status-on';
        }
    } else {
        status = 'Disabled';
    }
}
/*
previewButton.addEventListener('click', previewNextRange);
muteButton.addEventListener('click', () => setVoiceIcon('img/Mic-Hud-Mute.png'));
sprechenButton.addEventListener('click', () => setVoiceIcon('img/Mic-Hud-Green.png'));
micAnButton.addEventListener('click', () => setVoiceIcon('img/Mic-Hud.png'));
*/
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'updateVoiceHUD') {
        voiceHud.classList.toggle('hidden', !data.show);

        if (data.show) {
            const range = parseInt(data.voiceRange);
            updateVoiceCircle(range);
            voiceRange.textContent = `${data.voiceRange}`;
            updateStatus(micStatus, 'Mic', data.micEnabled, data.micDisabled, data.isSpeaking);
            
            // Update mic icon
            if (!data.micEnabled) {
                setVoiceIcon('img/Mic-Hud-Mute.png');
            } else if (data.isSpeaking) {
                setVoiceIcon('img/Mic-Hud.png');
            } else {
                setVoiceIcon('img/Mic-Hud-Green.png');
            }
        }
    } else if (data.action === 'setVisibility') {
        voiceHud.classList.toggle('hidden', !data.show);

    } else if (data.action === 'updateVoiceRange') {
        updateVoiceRange(data.range);
    }
});