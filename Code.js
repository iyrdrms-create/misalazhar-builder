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
    var doc = DocumentApp.openById(fileId);
    var body = doc.getBody();

    var questions = parseQuestions(body);

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

function parseQuestions(body) {
  var paragraphs = body.getParagraphs();
  var questions = [];

  var currentQuestionText = [];
  var currentOptions = [];

  for (var i = 0; i < paragraphs.length; i++) {
    var p = paragraphs[i];
    var text = p.getText().trim();
    if (text === '') continue;

    var isListItem = (p.getType() === DocumentApp.ElementType.LIST_ITEM);
    var optionMatch = text.match(/^\s*([A-Ea-e])[\.\)]\s*(.+)/);

    if (optionMatch) {
      currentOptions.push(optionMatch[2].trim());
    }
    else if (isListItem && currentQuestionText.length > 0) {
      currentOptions.push(text);
    }
    else {
      if (currentOptions.length > 0) {
        questions.push({
          text: currentQuestionText.join("\n").trim(),
          options: currentOptions
        });
        currentQuestionText = [];
        currentOptions = [];
      }

      var qMatch = text.match(/^\d+[\.\)]\s*(.+)/);
      if (qMatch) {
        currentQuestionText.push(qMatch[1].trim());
      } else {
        currentQuestionText.push(text);
      }
    }
  }

  if (currentQuestionText.length > 0 && currentOptions.length >= 2) {
    questions.push({
      text: currentQuestionText.join("\n").trim(),
      options: currentOptions
    });
  }

  return questions;
}
