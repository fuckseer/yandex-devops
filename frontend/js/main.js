"use strict";

const adsListElement = document.querySelector(".ads-list");
const API_BASE_URL = 'https://d5dgjv3apnbg41cgnrfl.apigw.yandexcloud.net';
const loader = document.querySelector('.loader');
const adsAddForm = document.querySelector('.ads-add-form');
const frontendVersionSpan = document.querySelector('.frontend-version');
const backendVersionSpan = document.querySelector('.backend-version');
const backendNameSpan = document.querySelector('.backend-name');

function initVersions(){
    if (typeof FRONTEND_VERSION !== 'undefined') {
        frontendVersionSpan.textContent = FRONTEND_VERSION;
    }

    fetch(`${API_BASE_URL}/version`, { method: 'GET' })
        .then(response => response.json())
        .then(version => {
            let backendVersion = version[0];
            let backendName = version[1];
            backendVersionSpan.textContent = backendVersion;
            backendNameSpan.textContent = backendName;
        })
}

initVersions();

async function addAd(author, title, content) {
    let response = await fetch(`${API_BASE_URL}/ads`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({author: author, text: content, title: title})
    });
    let result = await response.json();

    return result;
}

function submitAdsAddFormHandler(e) {
    e.preventDefault();
    const form = e.target;
    const formFields = form.elements;
    const fieldsToClear = [formFields.author, formFields.title, formFields.text];
    const author = formFields.author.value; 
    const title = formFields.title.value;
    const content = formFields.text.value;

    if (!author || !title || !content){
        return;
    }

    addAd(author, title, content)
        .then((ad) => {
            let adItem = createAdItem(ad.author,  ad.title, ad.text, ad.created_at);
            adsListElement.appendChild(adItem);
            fieldsToClear.forEach(field => {
                field.value = "";
            })
        })
}

adsAddForm.addEventListener("submit", submitAdsAddFormHandler);


function createAdItem(author, title, text, createdAt){
    let container = document.createElement('li');
    let titleEl = document.createElement('h2');
    let authorEl = document.createElement('p');
    let textEl = document.createElement('p');
    let createdAtEl = document.createElement('i');


    container.classList.add("ads-item");
    titleEl.textContent = title;
    textEl.textContent = text;
    authorEl.textContent = author;
    createdAtEl.textContent = createdAt;

    container.appendChild(titleEl);
    container.appendChild(authorEl);
    container.appendChild(textEl);
    container.appendChild(createdAtEl);

    return container;
};   

async function initAdsList() {
    let response = await fetch(`${API_BASE_URL}/ads`, {
        method: 'GET'
    });
    let result = await response.json();

    return result;
}

initAdsList().then((res) => {
    res.sort((ad1, ad2) => new Date(ad1.created_at) - new Date(ad2.created_at));

    res.forEach(ad => {
        let adItem = createAdItem(ad.author, ad.title, ad.text, ad.created_at);
        adsListElement.appendChild(adItem);
        loader.classList.add('disabled');
    });
});