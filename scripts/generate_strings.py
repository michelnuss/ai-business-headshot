#!/usr/bin/env python3
"""Write Localizable.xcstrings and InfoPlist.xcstrings (en, es, pt, fr)."""

import json
from pathlib import Path

ROOT = Path("/workspace/Headshot")

# key: {lang: value}
STRINGS = {
    "studio.title": {
        "en": "Headshot",
        "es": "Headshot",
        "pt": "Headshot",
        "fr": "Headshot",
    },
    "studio.startOver": {
        "en": "Start over",
        "es": "Empezar de nuevo",
        "pt": "Começar de novo",
        "fr": "Recommencer",
    },
    "studio.settings": {
        "en": "Settings",
        "es": "Ajustes",
        "pt": "Ajustes",
        "fr": "Réglages",
    },
    "studio.camera": {
        "en": "Camera",
        "es": "Cámara",
        "pt": "Câmera",
        "fr": "Appareil photo",
    },
    "studio.library": {
        "en": "Photos",
        "es": "Fotos",
        "pt": "Fotos",
        "fr": "Photos",
    },
    "studio.create": {
        "en": "Create headshot",
        "es": "Crear foto profesional",
        "pt": "Criar foto profissional",
        "fr": "Créer la photo pro",
    },
    "studio.share": {
        "en": "Share",
        "es": "Compartir",
        "pt": "Compartilhar",
        "fr": "Partager",
    },
    "studio.save": {
        "en": "Save",
        "es": "Guardar",
        "pt": "Salvar",
        "fr": "Enregistrer",
    },
    "studio.retry": {
        "en": "Try again",
        "es": "Intentar de nuevo",
        "pt": "Tentar de novo",
        "fr": "Réessayer",
    },
    "studio.ok": {
        "en": "OK",
        "es": "OK",
        "pt": "OK",
        "fr": "OK",
    },
    "settings.done": {
        "en": "Done",
        "es": "Listo",
        "pt": "OK",
        "fr": "OK",
    },
    "studio.mode.cloud": {
        "en": "Cloud studio",
        "es": "Estudio en la nube",
        "pt": "Estúdio na nuvem",
        "fr": "Studio en ligne",
    },
    "studio.mode.device": {
        "en": "On this iPhone",
        "es": "En este iPhone",
        "pt": "Neste iPhone",
        "fr": "Sur cet iPhone",
    },
    "studio.mode.cloud.a11y": {
        "en": "Using cloud studio",
        "es": "Usando el estudio en la nube",
        "pt": "Usando o estúdio na nuvem",
        "fr": "Studio en ligne activé",
    },
    "studio.mode.device.a11y": {
        "en": "Using studio on this iPhone",
        "es": "Usando el estudio en este iPhone",
        "pt": "Usando o estúdio neste iPhone",
        "fr": "Studio sur cet iPhone",
    },
    "studio.empty.title": {
        "en": "Take a photo or choose one",
        "es": "Toma una foto o elige una",
        "pt": "Tire uma foto ou escolha uma",
        "fr": "Prenez une photo ou choisissez-en une",
    },
    "studio.empty.body": {
        "en": "For job applications, visas, and professional profiles. The studio keeps you looking like you.",
        "es": "Para postulaciones de trabajo, visas y perfiles profesionales. El estudio te deja viéndote como tú.",
        "pt": "Para candidaturas, vistos e perfis profissionais. O estúdio mantém a sua cara.",
        "fr": "Pour les candidatures, visas et profils professionnels. Le studio vous laisse ressembler à vous-même.",
    },
    "studio.caption.empty": {
        "en": "Lighting, background, and clothes only. Your face stays yours.",
        "es": "Solo luz, fondo y ropa. Tu cara no cambia.",
        "pt": "Só luz, fundo e roupa. O seu rosto continua o mesmo.",
        "fr": "Lumière, fond et vêtements seulement. Votre visage reste le vôtre.",
    },
    "studio.caption.ready": {
        "en": "Face the camera in good light. A simple snapshot is enough.",
        "es": "Mira a la cámara con buena luz. Una foto simple alcanza.",
        "pt": "Olhe para a câmera com boa luz. Uma foto simples basta.",
        "fr": "Regardez l’appareil en bonne lumière. Une photo simple suffit.",
    },
    "studio.caption.generating.cloud": {
        "en": "Sending a small photo. Slow internet is OK — you can retry if it fails.",
        "es": "Enviando una foto pequeña. Si la red es lenta, espera o reintenta.",
        "pt": "Enviando uma foto pequena. Internet lenta serve — dá para tentar de novo.",
        "fr": "Envoi d’une petite photo. Un réseau lent convient — vous pourrez réessayer.",
    },
    "studio.caption.generating.device": {
        "en": "Working on this iPhone: crop, background, and light. No photo is uploaded.",
        "es": "Trabaja en este iPhone: recorte, fondo y luz. No se sube la foto.",
        "pt": "Neste iPhone: recorte, fundo e luz. Nenhuma foto é enviada.",
        "fr": "Traitement sur cet iPhone : cadrage, fond et lumière. Aucun envoi.",
    },
    "studio.caption.result": {
        "en": "Slide to compare. Save or share when it looks right.",
        "es": "Desliza para comparar. Guarda o comparte cuando te convenza.",
        "pt": "Deslize para comparar. Salve ou compartilhe quando gostar.",
        "fr": "Glissez pour comparer. Enregistrez ou partagez si c’est bon.",
    },
    "studio.caption.failed": {
        "en": "Your original photo is unchanged. Try again, or pick another.",
        "es": "Tu foto original no se modificó. Reintenta o elige otra.",
        "pt": "Sua foto original não mudou. Tente de novo ou escolha outra.",
        "fr": "Votre photo d’origine n’a pas changé. Réessayez ou choisissez-en une autre.",
    },
    "studio.cameraUnavailable.title": {
        "en": "Camera isn’t available",
        "es": "La cámara no está disponible",
        "pt": "A câmera não está disponível",
        "fr": "Appareil photo indisponible",
    },
    "studio.cameraUnavailable.choose": {
        "en": "Choose a photo",
        "es": "Elegir una foto",
        "pt": "Escolher uma foto",
        "fr": "Choisir une photo",
    },
    "studio.cameraUnavailable.message": {
        "en": "This device has no camera. Choose a photo from your library instead.",
        "es": "Este dispositivo no tiene cámara. Elige una foto de tu galería.",
        "pt": "Este aparelho não tem câmera. Escolha uma foto da galeria.",
        "fr": "Cet appareil n’a pas de caméra. Choisissez une photo dans la galerie.",
    },
    "studio.photo.a11y": {
        "en": "Selected portrait",
        "es": "Retrato seleccionado",
        "pt": "Retrato selecionado",
        "fr": "Portrait sélectionné",
    },
    "studio.compare.a11y": {
        "en": "Before and after comparison",
        "es": "Comparación antes y después",
        "pt": "Comparação antes e depois",
        "fr": "Comparaison avant / après",
    },
    "studio.before": {
        "en": "Your photo",
        "es": "Tu foto",
        "pt": "Sua foto",
        "fr": "Votre photo",
    },
    "studio.after": {
        "en": "Studio",
        "es": "Estudio",
        "pt": "Estúdio",
        "fr": "Studio",
    },
    "studio.generating.a11y": {
        "en": "Creating headshot",
        "es": "Creando foto profesional",
        "pt": "Criando foto profissional",
        "fr": "Création de la photo pro",
    },
    "status.reading": {
        "en": "Reading the portrait…",
        "es": "Leyendo el retrato…",
        "pt": "Lendo o retrato…",
        "fr": "Lecture du portrait…",
    },
    "status.identity": {
        "en": "Keeping your face yours…",
        "es": "Tu cara se mantiene…",
        "pt": "Mantendo o seu rosto…",
        "fr": "Votre visage reste le vôtre…",
    },
    "status.light": {
        "en": "Setting studio light…",
        "es": "Ajustando la luz de estudio…",
        "pt": "Ajustando a luz de estúdio…",
        "fr": "Réglage de la lumière…",
    },
    "status.background": {
        "en": "Cleaning the background…",
        "es": "Limpiando el fondo…",
        "pt": "Limpando o fundo…",
        "fr": "Nettoyage du fond…",
    },
    "status.finishing": {
        "en": "Finishing the headshot…",
        "es": "Terminando la foto…",
        "pt": "Finalizando a foto…",
        "fr": "Finition de la photo…",
    },
    "toast.saved": {
        "en": "Saved to Photos",
        "es": "Guardada en Fotos",
        "pt": "Salva em Fotos",
        "fr": "Enregistrée dans Photos",
    },
    "error.loadFailed": {
        "en": "That photo couldn’t be opened. Try another one.",
        "es": "No se pudo abrir esa foto. Prueba con otra.",
        "pt": "Não foi possível abrir essa foto. Tente outra.",
        "fr": "Impossible d’ouvrir cette photo. Essayez-en une autre.",
    },
    "error.missingKey": {
        "en": "No cloud key is set. Add one in Settings, or keep using the studio on this iPhone.",
        "es": "No hay clave de nube. Agrégala en Ajustes o sigue usando el estudio en este iPhone.",
        "pt": "Não há chave da nuvem. Adicione em Ajustes ou use o estúdio neste iPhone.",
        "fr": "Aucune clé cloud. Ajoutez-en une dans Réglages, ou gardez le studio sur cet iPhone.",
    },
    "error.invalidImage": {
        "en": "That photo couldn’t be prepared. Try a different one.",
        "es": "No se pudo preparar esa foto. Prueba con otra.",
        "pt": "Não foi possível preparar essa foto. Tente outra.",
        "fr": "Cette photo n’a pas pu être préparée. Essayez-en une autre.",
    },
    "error.unauthorized": {
        "en": "The cloud key was rejected. Check it in Settings.",
        "es": "La clave de nube fue rechazada. Revísala en Ajustes.",
        "pt": "A chave da nuvem foi recusada. Confira em Ajustes.",
        "fr": "La clé cloud a été refusée. Vérifiez-la dans Réglages.",
    },
    "error.quota": {
        "en": "The cloud studio is out of credit. Try again later, or use the studio on this iPhone.",
        "es": "El estudio en la nube no tiene crédito. Prueba más tarde o usa este iPhone.",
        "pt": "O estúdio na nuvem está sem crédito. Tente mais tarde ou use neste iPhone.",
        "fr": "Le studio en ligne n’a plus de crédit. Réessayez plus tard ou utilisez cet iPhone.",
    },
    "error.saveDenied": {
        "en": "Photos access is off. Turn it on in Settings, or use Share.",
        "es": "El acceso a Fotos está apagado. Actívalo en Ajustes o usa Compartir.",
        "pt": "O acesso a Fotos está desligado. Ative em Ajustes ou use Compartilhar.",
        "fr": "L’accès à Photos est désactivé. Activez-le dans Réglages, ou utilisez Partager.",
    },
    "error.saveFailed": {
        "en": "Couldn’t save to Photos. Try Share instead.",
        "es": "No se pudo guardar en Fotos. Prueba Compartir.",
        "pt": "Não foi possível salvar em Fotos. Tente Compartilhar.",
        "fr": "Impossible d’enregistrer dans Photos. Utilisez Partager.",
    },
    "error.transport": {
        "en": "Couldn’t reach the studio. Check your connection and try again.",
        "es": "No se pudo conectar al estudio. Revisa tu red e intenta de nuevo.",
        "pt": "Não foi possível alcançar o estúdio. Confira a conexão e tente de novo.",
        "fr": "Impossible de joindre le studio. Vérifiez la connexion et réessayez.",
    },
    "error.badURL": {
        "en": "The studio address in the app is not valid.",
        "es": "La dirección del estudio en la app no es válida.",
        "pt": "O endereço do estúdio no app não é válido.",
        "fr": "L’adresse du studio dans l’app n’est pas valide.",
    },
    "error.httpStatus": {
        "en": "The studio returned an error (%d). Try again in a moment.",
        "es": "El estudio devolvió un error (%d). Intenta de nuevo en un momento.",
        "pt": "O estúdio devolveu um erro (%d). Tente de novo em instantes.",
        "fr": "Le studio a renvoyé une erreur (%d). Réessayez dans un instant.",
    },
    "error.emptyResponse": {
        "en": "The studio sent back an empty photo. Try again.",
        "es": "El estudio devolvió una foto vacía. Intenta de nuevo.",
        "pt": "O estúdio enviou uma foto vazia. Tente de novo.",
        "fr": "Le studio a renvoyé une photo vide. Réessayez.",
    },
    "error.unusableImage": {
        "en": "The studio didn’t return a usable photo. Try another.",
        "es": "El estudio no devolvió una foto usable. Prueba con otra.",
        "pt": "O estúdio não devolveu uma foto utilizável. Tente outra.",
        "fr": "Le studio n’a pas renvoyé une photo utilisable. Essayez-en une autre.",
    },
    "error.genericAPI": {
        "en": "The studio returned an error. Try again.",
        "es": "El estudio devolvió un error. Intenta de nuevo.",
        "pt": "O estúdio devolveu um erro. Tente de novo.",
        "fr": "Le studio a renvoyé une erreur. Réessayez.",
    },
    "settings.title": {
        "en": "Settings",
        "es": "Ajustes",
        "pt": "Ajustes",
        "fr": "Réglages",
    },
    "settings.key.header": {
        "en": "Cloud studio key",
        "es": "Clave del estudio en la nube",
        "pt": "Chave do estúdio na nuvem",
        "fr": "Clé du studio en ligne",
    },
    "settings.key.save": {
        "en": "Save key",
        "es": "Guardar clave",
        "pt": "Salvar chave",
        "fr": "Enregistrer la clé",
    },
    "settings.key.remove": {
        "en": "Remove key",
        "es": "Quitar clave",
        "pt": "Remover chave",
        "fr": "Supprimer la clé",
    },
    "settings.key.placeholder": {
        "en": "Paste key",
        "es": "Pegar clave",
        "pt": "Colar chave",
        "fr": "Coller la clé",
    },
    "settings.footer.runtime": {
        "en": "Optional. Without a key, photos stay on this iPhone. With a key, the portrait is sent to OpenAI to make the studio photo. The key is stored only on this device.",
        "es": "Opcional. Sin clave, las fotos se quedan en este iPhone. Con clave, el retrato se envía a OpenAI. La clave solo se guarda en este aparato.",
        "pt": "Opcional. Sem chave, as fotos ficam neste iPhone. Com chave, o retrato vai para a OpenAI. A chave fica só neste aparelho.",
        "fr": "Facultatif. Sans clé, les photos restent sur cet iPhone. Avec une clé, le portrait est envoyé à OpenAI. La clé reste sur cet appareil.",
    },
    "settings.footer.compileTime": {
        "en": "A key is already set in the app build, so it takes priority. For store builds, leave that empty and paste a key here instead.",
        "es": "Ya hay una clave en esta versión de la app y tiene prioridad. En versiones de tienda, déjala vacía y pégala aquí.",
        "pt": "Já há uma chave nesta versão do app e ela tem prioridade. Nas versões da loja, deixe vazia e cole aqui.",
        "fr": "Une clé est déjà dans cette version de l’app et elle a priorité. Pour l’App Store, laissez-la vide et collez-en une ici.",
    },
    "settings.build": {
        "en": "This version",
        "es": "Esta versión",
        "pt": "Esta versão",
        "fr": "Cette version",
    },
    "settings.bundle": {
        "en": "Bundle ID",
        "es": "Bundle ID",
        "pt": "Bundle ID",
        "fr": "Bundle ID",
    },
    "settings.version": {
        "en": "Version",
        "es": "Versión",
        "pt": "Versão",
        "fr": "Version",
    },
    "settings.studio": {
        "en": "Studio",
        "es": "Estudio",
        "pt": "Estúdio",
        "fr": "Studio",
    },
    "settings.studio.cloud": {
        "en": "Cloud",
        "es": "Nube",
        "pt": "Nuvem",
        "fr": "Nuage",
    },
    "settings.studio.device": {
        "en": "This iPhone",
        "es": "Este iPhone",
        "pt": "Este iPhone",
        "fr": "Cet iPhone",
    },
}

INFO = {
    "NSCameraUsageDescription": {
        "en": "Headshot uses the camera to take a portrait for job, visa, and professional photos.",
        "es": "Headshot usa la cámara para tomar un retrato para trabajo, visa o perfil profesional.",
        "pt": "O Headshot usa a câmera para um retrato de trabalho, visto ou perfil profissional.",
        "fr": "Headshot utilise l’appareil photo pour un portrait professionnel, visa ou candidature.",
    },
    "NSPhotoLibraryAddUsageDescription": {
        "en": "Headshot saves the finished studio photo to your library.",
        "es": "Headshot guarda la foto de estudio terminada en tu galería.",
        "pt": "O Headshot salva a foto de estúdio pronta na sua galeria.",
        "fr": "Headshot enregistre la photo studio dans votre bibliothèque.",
    },
    "NSPhotoLibraryUsageDescription": {
        "en": "Headshot uses your photo library so you can choose a portrait to turn into a studio photo.",
        "es": "Headshot usa tu galería para que elijas un retrato y lo convierta en foto de estudio.",
        "pt": "O Headshot usa sua galeria para você escolher um retrato e transformá-lo em foto de estúdio.",
        "fr": "Headshot utilise votre photothèque pour choisir un portrait à transformer.",
    },
    "CFBundleDisplayName": {
        "en": "Headshot",
        "es": "Headshot",
        "pt": "Headshot",
        "fr": "Headshot",
    },
}


def catalog(entries: dict) -> dict:
    strings = {}
    for key, langs in entries.items():
        loc = {}
        for lang, value in langs.items():
            loc[lang] = {"stringUnit": {"state": "translated", "value": value}}
        strings[key] = {
            "extractionState": "manual",
            "localizations": loc,
        }
    return {
        "sourceLanguage": "en",
        "strings": strings,
        "version": "1.1",
    }


def main() -> None:
    (ROOT / "Localizable.xcstrings").write_text(
        json.dumps(catalog(STRINGS), ensure_ascii=False, indent=2) + "\n"
    )
    (ROOT / "InfoPlist.xcstrings").write_text(
        json.dumps(catalog(INFO), ensure_ascii=False, indent=2) + "\n"
    )
    print(f"wrote {len(STRINGS)} UI strings and {len(INFO)} Info.plist strings")


if __name__ == "__main__":
    main()
