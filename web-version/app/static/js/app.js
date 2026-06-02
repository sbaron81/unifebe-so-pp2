let studentId = localStorage.getItem('studentId');
let studentNames = JSON.parse(localStorage.getItem('studentNames') || '[]');
let currentGroupNames = []; 

// --- Group Management Functions (Top for visibility) ---

function addStudentToList() {
    const input = document.getElementById('login-name');
    const name = input.value.trim();
    
    if (name.length < 3) {
        alert("O nome deve ter pelo menos 3 caracteres.");
        return;
    }
    
    if (currentGroupNames.includes(name)) {
        alert("Este aluno já foi adicionado ao grupo.");
        return;
    }
    
    currentGroupNames.push(name);
    input.value = '';
    input.focus();
    renderStudentList();
}

function removeStudentFromList(index) {
    currentGroupNames.splice(index, 1);
    renderStudentList();
}

function renderStudentList() {
    const list = document.getElementById('students-list');
    const btnStart = document.getElementById('btn-start');
    
    if (!list || !btnStart) return;

    if (currentGroupNames.length === 0) {
        list.innerHTML = '<p class="text-gray-500 italic text-center py-2">Nenhum aluno adicionado</p>';
        btnStart.disabled = true;
        return;
    }

    btnStart.disabled = false;
    list.innerHTML = currentGroupNames.map((name, idx) => `
        <div class="flex justify-between items-center bg-gray-900 p-2 rounded border border-gray-700 mb-2">
            <span class="font-medium">${name}</span>
            <button type="button" onclick="removeStudentFromList(${idx})" class="text-red-500 hover:text-red-400 p-1">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `).join('');
}

function login() {
    if (currentGroupNames.length === 0) {
        alert("Adicione pelo menos um aluno para iniciar.");
        return;
    }
    
    studentNames = currentGroupNames;
    const sortedNames = [...studentNames].sort();
    studentId = sortedNames.join('_').toLowerCase().replace(/\s+/g, '_') + '_' + Date.now();
    
    localStorage.setItem('studentId', studentId);
    localStorage.setItem('studentNames', JSON.stringify(studentNames));
    
    showDashboard();
}

function showDashboard() {
    const overlay = document.getElementById('id-overlay');
    const captureArea = document.getElementById('capture-area');
    
    if (overlay) overlay.classList.add('hidden');
    if (captureArea) {
        captureArea.classList.remove('opacity-0', 'pointer-events-none');
        captureArea.classList.add('opacity-100');
    }
    
    const studentNameInput = document.getElementById('student-name');
    if (studentNameInput) studentNameInput.value = studentNames.join(', ');
    
    updateDate();
    fetchStats();
    fetchPrerequisites();
    fetchActivities();
    startQuiz();
}

// --- System Stats & Activities ---

async function fetchPrerequisites() {
    try {
        const response = await fetch('/api/prerequisites');
        const data = await response.json();
        const list = document.getElementById('prerequisites-list');
        if (!list) return;

        list.innerHTML = data.map(item => `
            <div class="flex items-center justify-between bg-gray-900/50 p-3 rounded border ${item.status ? 'border-green-900 bg-green-900/10' : 'border-red-900 bg-red-900/10'}">
                <span class="text-sm font-medium ${item.status ? 'text-gray-300' : 'text-red-400'}">${item.title}</span>
                <i class="fas ${item.status ? 'fa-check-circle text-green-500' : 'fa-times-circle text-red-500'}"></i>
            </div>
        `).join('');
    } catch (error) {
        console.error('Erro ao buscar pré-requisitos:', error);
    }
}

async function fetchStats() {
    try {
        const response = await fetch('/api/stats');
        const data = await response.json();
        
        document.getElementById('cpu-percent').innerText = `${data.cpu.percent}%`;
        document.getElementById('cpu-bar').style.width = `${data.cpu.percent}%`;
        
        document.getElementById('mem-percent').innerText = `${data.memory.percent}%`;
        document.getElementById('mem-bar').style.width = `${data.memory.percent}%`;
        
        document.getElementById('swap-percent').innerText = `${data.memory.swap_percent}%`;
        document.getElementById('swap-bar').style.width = `${data.memory.swap_percent}%`;
        
        // Render Disk Partitions
        const diskContainer = document.getElementById('disk-partitions-container');
        if (diskContainer && data.disk && data.disk.partitions) {
            diskContainer.innerHTML = data.disk.partitions.map(p => `
                <div class="bg-gray-800 p-4 rounded-lg border border-gray-700">
                    <div class="flex justify-between items-start mb-1">
                        <h3 class="text-gray-400 text-xs uppercase font-bold truncate" title="${p.mountpoint}">Disco: ${p.mountpoint}</h3>
                        <span class="text-xs text-gray-500 font-mono">${p.device}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xl font-bold">${p.percent}%</span>
                        <i class="fas fa-hdd text-blue-500 text-lg"></i>
                    </div>
                    <div class="w-full bg-gray-700 rounded-full h-1.5 mt-3">
                        <div class="h-1.5 rounded-full ${p.percent > 90 ? 'bg-red-500' : p.percent > 70 ? 'bg-yellow-500' : 'bg-blue-500'}" 
                             style="width: ${p.percent}%"></div>
                    </div>
                </div>
            `).join('');
        }

        document.getElementById('connection-status').classList.remove('text-red-400');
        document.getElementById('connection-status').classList.add('text-green-400');
        document.getElementById('connection-status').innerHTML = '<i class="fas fa-circle mr-1"></i> Conectado';
    } catch (error) {
        const status = document.getElementById('connection-status');
        if (status) {
            status.classList.remove('text-green-400');
            status.classList.add('text-red-400');
            status.innerHTML = '<i class="fas fa-exclamation-triangle mr-1"></i> Erro de Conexão';
        }
    }
}

async function fetchActivities() {
    if (!studentId) return;
    try {
        const response = await fetch('/api/activities', {
            headers: { 'X-Student-Id': studentId }
        });
        const activities = await response.json();
        const grid = document.getElementById('activities-grid');
        if (!grid) return;
        grid.innerHTML = '';

        activities.forEach(activity => {
            const card = document.createElement('div');
            const statusColors = {
                'pending': 'border-gray-700 bg-gray-800',
                'success': 'border-green-500 bg-green-900/20',
                'failed': 'border-red-500 bg-red-900/20'
            };
            const statusIcon = {
                'pending': 'fa-clock text-gray-500',
                'success': 'fa-check-circle text-green-500',
                'failed': 'fa-times-circle text-red-500'
            };

            card.className = `${statusColors[activity.status]} p-5 rounded-lg border-2 cursor-pointer hover:scale-[1.02] transition-transform flex flex-col justify-between`;
            card.onclick = () => openModal(activity);
            
            card.innerHTML = `
                <div>
                    <div class="flex justify-between items-start mb-2">
                        <span class="text-xs font-bold uppercase text-blue-400">${activity.category}</span>
                        <i class="fas ${statusIcon[activity.status]}"></i>
                    </div>
                    <h4 class="font-bold text-lg">${activity.title}</h4>
                    <p class="text-sm text-gray-400 mt-2">${activity.description}</p>
                </div>
                <div class="mt-4 text-xs font-mono text-gray-500">ID: ${activity.id}</div>
            `;
            grid.appendChild(card);
        });
    } catch (error) {
        console.error('Erro ao buscar atividades:', error);
    }
}

// --- Validation Modal ---

function openModal(activity) {
    document.getElementById('modal-title').innerText = activity.title;
    document.getElementById('modal-desc').innerText = activity.description;
    document.getElementById('user-input').value = '';
    document.getElementById('validation-msg').classList.add('hidden');
    
    const inputContainer = document.getElementById('input-container');
    if (activity.type === 'passive') {
        inputContainer.classList.add('hidden');
    } else {
        inputContainer.classList.remove('hidden');
    }
    
    document.getElementById('modal').classList.remove('hidden');
    document.getElementById('btn-validate').onclick = () => validateActivity(activity.id);
}

function closeModal() {
    document.getElementById('modal').classList.add('hidden');
}

async function validateActivity(id) {
    const input = document.getElementById('user-input').value;
    const btn = document.getElementById('btn-validate');
    const msg = document.getElementById('validation-msg');
    
    if (!btn || !msg) return;

    btn.disabled = true;
    btn.innerText = 'Validando...';
    
    try {
        const response = await fetch('/api/validate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-Student-Id': studentId
            },
            body: JSON.stringify({activity_id: id, user_input: input})
        });
        const result = await response.json();
        
        msg.classList.remove('hidden', 'bg-red-500/20', 'text-red-400', 'bg-green-500/20', 'text-green-400');
        
        if (result.success) {
            msg.innerText = "✅ OK";
            msg.classList.add('bg-green-500/20', 'text-green-400');
        } else {
            msg.innerText = result.message;
            msg.classList.add('bg-red-500/20', 'text-red-400');
        }

        // Fecha a janela e atualiza o dashboard em todos os casos (Sucesso ou Erro)
        setTimeout(() => {
            closeModal();
            fetchActivities();
        }, 800);
    } catch (error) {
        console.error('Erro na validação:', error);
        msg.innerText = "Erro ao validar atividade.";
        msg.classList.remove('hidden');
        msg.classList.add('bg-red-500/20', 'text-red-400');
    } finally {
        btn.disabled = false;
        btn.innerText = 'Validar';
    }
}

// --- Quiz Engine ---

let quizData = [];
let userAnswers = [];
let currentQuestionIdx = 0;

async function startQuiz() {
    try {
        const response = await fetch('/api/quiz');
        quizData = await response.json();
        userAnswers = [];
        currentQuestionIdx = 0;
        renderQuestion();
    } catch (error) {
        console.error('Erro ao buscar quiz:', error);
    }
}

function renderQuestion() {
    const container = document.getElementById('quiz-container');
    const progress = document.getElementById('quiz-progress');
    if (!container) return;
    
    if (currentQuestionIdx >= quizData.length) {
        showQuizResults();
        return;
    }

    const q = quizData[currentQuestionIdx];
    if (progress) progress.innerText = `Questão ${currentQuestionIdx + 1} de ${quizData.length}`;
    
    container.innerHTML = `
        <h3 class="text-xl font-medium mb-6 leading-relaxed">${q.question}</h3>
        <div class="space-y-3">
            ${q.options.map((opt, idx) => `
                <button type="button" onclick="saveAnswer('${opt.replace(/'/g, "\\'")}')" class="w-full text-left p-4 bg-gray-700 hover:bg-gray-650 border border-gray-600 rounded-lg transition-colors focus:outline-none focus:border-blue-500">
                    <span class="inline-block w-8 h-8 line-height-8 text-center bg-gray-600 rounded-full mr-3 text-sm font-bold">${String.fromCharCode(65 + idx)}</span>
                    ${opt}
                </button>
            `).join('')}
        </div>
    `;
}

function saveAnswer(answer) {
    userAnswers.push({
        question: quizData[currentQuestionIdx].question,
        user_answer: answer,
        correct_answer: quizData[currentQuestionIdx].correct_hidden
    });
    currentQuestionIdx++;
    renderQuestion();
}

async function showQuizResults() {
    const container = document.getElementById('quiz-container');
    const progress = document.getElementById('quiz-progress');
    if (progress) progress.innerText = "Finalizado";

    container.innerHTML = `<div class="text-center py-4"><i class="fas fa-spinner fa-spin text-3xl text-blue-500"></i><p class="mt-2">Processando resultados...</p></div>`;

    try {
        const response = await fetch('/api/quiz/validate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(userAnswers)
        });
        const result = await response.json();
        
        container.innerHTML = `
            <div class="text-center mb-8">
                <i class="fas fa-trophy text-6xl text-yellow-500 mb-4"></i>
                <h3 class="text-3xl font-bold mb-2">Resultado Final</h3>
                <p class="text-2xl text-blue-400 font-bold">${result.score} de ${result.total} Acertos</p>
                <button type="button" onclick="startQuiz()" class="mt-6 bg-blue-600 hover:bg-blue-500 px-6 py-2 rounded font-bold">
                    <i class="fas fa-redo mr-2"></i>Reiniciar Questionário
                </button>
            </div>
            <div class="space-y-4 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                ${result.details.map((det, idx) => `
                    <div class="p-4 rounded-lg border ${det.is_correct ? 'border-green-500 bg-green-900/10' : 'border-red-500 bg-red-900/10'}">
                        <div class="flex justify-between items-start mb-2">
                            <span class="text-sm font-bold text-gray-400">Questão ${idx + 1}</span>
                            <i class="fas ${det.is_correct ? 'fa-check-circle text-green-500' : 'fa-times-circle text-red-500'}"></i>
                        </div>
                        <p class="text-sm mb-3">${det.question}</p>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs">
                            <div class="${det.is_correct ? 'text-green-400' : 'text-red-400'}">
                                <strong>Sua resposta:</strong> ${det.user_answer}
                            </div>
                            ${!det.is_correct ? `
                            <div class="text-green-400">
                                <strong>Correta:</strong> ${det.correct_answer}
                            </div>
                            ` : ''}
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    } catch (error) {
        container.innerHTML = `<div class="text-red-500 text-center">Erro ao carregar resultados.</div>`;
    }
}

// --- Helpers & Initial Fetch ---

function updateDate() {
    const dateEl = document.getElementById('current-date');
    if (dateEl) {
        const now = new Date();
        dateEl.innerText = now.toLocaleDateString('pt-BR');
    }
}

function generatePDF() {
    const studentNameVal = document.getElementById('student-name').value || 'estudante_sem_nome';
    const element = document.getElementById('capture-area');
    const opt = {
        margin:       10,
        filename:     `relatorio_so_${studentNameVal.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.pdf`,
        image:        { type: 'jpeg', quality: 0.98 },
        html2canvas:  { scale: 2, backgroundColor: '#111827' },
        jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
    };
    
    const btn = document.querySelector('button[onclick="generatePDF()"]');
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Gerando...';
    btn.disabled = true;

    html2pdf().set(opt).from(element).save().then(() => {
        btn.innerHTML = originalText;
        btn.disabled = false;
    });
}

async function confirmReset() {
    if (confirm("Tem certeza que deseja zerar todo o progresso deste grupo?")) {
        try {
            await fetch('/api/reset', { 
                method: 'POST',
                headers: { 'X-Student-Id': studentId }
            });
            localStorage.removeItem('studentId');
            localStorage.removeItem('studentNames');
            location.reload();
        } catch (error) {
            alert("Erro ao resetar ambiente.");
        }
    }
}

window.onload = () => {
    if (studentId && studentNames && studentNames.length > 0) {
        showDashboard();
    }
    setInterval(fetchStats, 2000);
    setInterval(fetchActivities, 10000);
    setInterval(fetchPrerequisites, 30000);
};
