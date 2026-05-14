function onOpen(e) {
  FormApp.getUi()
    .createAddonMenu()
    .addItem('Buka Auto Form Builder', 'showSidebar')
    .addToUi();
}

function onInstall(e) {
  onOpen(e);
}

function showSidebar() {
  var html = HtmlService.createHtmlOutputFromFile('Sidebar')
    .setTitle('Auto Form Builder')
    .setWidth(300);
  FormApp.getUi().showSidebar(html);
}

function getRecentDocs() {
  var docs = [];
  var files = DriveApp.searchFiles('mimeType = "' + MimeType.GOOGLE_DOCS + '"');
  var count = 0;

  while (files.hasNext() && count < 20) {
    var file = files.next();
    docs.push({
      id: file.getId(),
      name: file.getName()
    });
    count++;
  }
  return docs;
}

function generateQuizFromDoc(fileId) {
  try {
    // Menggunakan Advanced Docs Service (Google Docs API)
    // Ini menghormati izin .readonly dan tidak butuh izin Akses Penuh
    var doc = Docs.Documents.get(fileId);
    var content = doc.body.content;
    var textContent = "";
    
    // Menggabungkan teks dari struktur data Docs API
    for (var i = 0; i < content.length; i++) {
      if (content[i].paragraph) {
        var elements = content[i].paragraph.elements;
        for (var j = 0; j < elements.length; j++) {
          if (elements[j].textRun) {
            textContent += elements[j].textRun.content;
          }
        }
      }
    }
    
    var lines = textContent.split(/\r?\n/);
    var questions = parseQuestionsFromText(lines);

    if (questions.length === 0) {
      return { success: false, message: "Tidak ada soal dengan format yang sesuai ditemukan di dokumen ini." };
    }

    var form = FormApp.getActiveForm();

    for (var i = 0; i < questions.length; i++) {
      var q = questions[i];
      var item = form.addMultipleChoiceItem();
      item.setTitle(q.text)
        .setChoiceValues(q.options)
        .setRequired(true);
    }

    return { success: true, message: "Berhasil menambahkan " + questions.length + " soal ke dalam Form!" };
  } catch (error) {
    return { success: false, message: "Error: " + error.toString() };
  }
}

function parseQuestionsFromText(lines) {
  var questions = [];
  var currentQuestionText = [];
  var currentOptions = [];

  for (var i = 0; i < lines.length; i++) {
    var text = lines[i].trim();
    if (text === '') continue;

    // Deteksi Pilihan Ganda (A. B. C. D. E.)
    var optionMatch = text.match(/^\s*([A-Ea-e])[\.\)]\s*(.+)/);

    if (optionMatch) {
      currentOptions.push(optionMatch[2].trim());
    }
    else {
      // Jika baris ini bukan pilihan, tapi kita sudah punya pilihan dari soal sebelumnya
      // Maka simpan soal sebelumnya dulu
      if (currentOptions.length > 0) {
        questions.push({
          text: currentQuestionText.join("\n").trim(),
          options: currentOptions
        });
        currentQuestionText = [];
        currentOptions = [];
      }

      // Cek apakah baris ini adalah awal soal baru (dimulai angka)
      var qMatch = text.match(/^\d+[\.\)]\s*(.+)/);
      if (qMatch) {
        currentQuestionText.push(qMatch[1].trim());
      } else {
        // Jika tidak ada angka, anggap ini sambungan teks soal
        currentQuestionText.push(text);
      }
    }
  }

  // Simpan soal terakhir
  if (currentQuestionText.length > 0 && currentOptions.length >= 2) {
    questions.push({
      text: currentQuestionText.join("\n").trim(),
      options: currentOptions
    });
  }

  return questions;
}
