# ComfyUI - Qwen-Image-2.1 (Docker Autonome)

Ce projet permet de faire tourner **ComfyUI** avec le modèle **Qwen-Image-2.1** dans un conteneur Docker optimisé avec accélération GPU NVIDIA.

Le projet est entièrement **autonome, portable et prêt à être partagé**.

---

## 🚀 Démarrage en 3 étapes

### 1. Cloner le projet
```bash
git clone <url-du-repo>
cd ComfyProject
```

### 2. Télécharger les modèles (automatisé)
Ce script vérifie et télécharge automatiquement les poids officiels optimisés INT8 ConvRot + CLIP + VAE :
```bash
./download_models.sh
```
*(Si vous n'avez pas installé `hf` ou Python sur votre machine hôte, le script utilisera automatiquement Docker pour télécharger les modèles).*

### 3. Lancer ComfyUI
```bash
./start.sh
# ou :
docker compose up -d
```

Ouvrez ensuite votre navigateur sur :
👉 **http://localhost:8188** (ou `http://<IP-DE-VOTRE-MACHINE>:8188`)

---

## ⚙️ Configuration (.env)

Pour personnaliser les chemins de stockage ou les paramètres GPU, copiez `.env.example` en `.env` :
```bash
cp .env.example .env
```

| Variable | Description | Défaut |
| :--- | :--- | :--- |
| `STORAGE_DIR` | Dossier hôte pour stocker les modèles et images générées | `./data` |
| `PORT` | Port d'écoute web | `8188` |
| `CLI_ARGS` | Arguments ComfyUI (gestion VRAM optimisée pour 8 Go - 16 Go) | `--listen 0.0.0.0 --port 8188 --reserve-vram 2.5 --lowvram --fp16-vae` |

> [!TIP]
> Si vous avez un disque SSD secondaire ou une partition dédiée avec plus d'espace, définissez par exemple `STORAGE_DIR=/mnt/storage/comfyui` dans votre `.env`.

---

## 🎨 Utilisation & Workflows

Les workflows sont automatiquement synchronisés dans ComfyUI au démarrage :
1. Dans l'interface ComfyUI, cliquez sur **Workflow > Open** (ou panneau latéral **Load**).
2. Sélectionnez **`Qwen_Image_2_1_t2i`** (Text-to-Image) ou **`Qwen_Image_2_1_image_edit`** (Image Edit).
3. Entrez votre prompt dans le nœud `Text Encode Qwen Image 2.1`.
4. Cliquez sur **Queue Prompt** (ou `Ctrl + Entrée`).

### Paramètres recommandés pour GPU 8 Go (RTX 3070, etc.) :
* **Résolution (`ResolutionSelector`)** : Choisissez **1.0 mégapixel** (1024x1024). Évitez le 2K (2048x2048) qui dépasse 8 Go de VRAM.
* **CFG** : Laissez à **1** (recommandé officiellement par l'équipe Qwen).
* **Steps** : 25 à 40 étapes avec le sampler `euler`.
* **Images avec transparence (RGBA)** : Entourez votre prompt par :
  `This is an RGBA format image with transparency. [Votre description]. The image has an alpha channel and a transparent background.`

---

## 🛠 Commandes utiles

* **Démarrer** : `./start.sh`
* **Arrêter** : `./stop.sh`
* **Voir les logs en direct** : `docker compose logs -f`
* **Mettre à jour les nœuds** : Utilisez le bouton **Manager** intégré directement dans l'interface ComfyUI.
