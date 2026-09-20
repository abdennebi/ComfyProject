# ComfyUI - Qwen-Image-2.1 (Docker)

Ce projet permet de faire tourner **ComfyUI** avec le modèle **Qwen-Image-2.1** dans un conteneur Docker optimisé avec accélération GPU NVIDIA.

---

## 🚀 Démarrage Rapide

### 1. Lancer ComfyUI
```bash
./start.sh
# ou directement :
docker compose up -d
```

### 2. Accéder à l'interface
Ouvrez votre navigateur sur :
👉 **http://localhost:8188** (ou `http://127.0.0.1:8188`)

### 3. Charger le Workflow Qwen-Image-2.1
Dans l'interface ComfyUI :
- Glissez-déposez le fichier [`workflows/Qwen_Image_2_1_t2i.json`](file:///home/abdennebi/Repos/ComfyProject/workflows/Qwen_Image_2_1_t2i.json) directement sur la fenêtre du navigateur, ou
- Cliquez sur **Workflow** (ou **Load**) dans le menu de droite et sélectionnez `workflows/Qwen_Image_2_1_t2i.json`.

---

## 🎨 Utilisation & Génération

### Modèles installés (optimisés INT8 ConvRot + BF16)
Les poids officiels optimisés de **Comfy-Org** ont été téléchargés et configurés :
- **Modèle de diffusion** : `diffusion_models/qwen_image_2.1_int8_convrot.safetensors`
- **Encodeur de texte (CLIP)** : `text_encoders/qwen3vl_8b_int8_convrot.safetensors`
- **VAE** : `vae/qwen_image_2.1_vae_bf16.safetensors`

### Paramètres recommandés
- **Prompt** : Votre description textuelle en anglais ou multilingue.
- **CFG** : Laissez à **1** (recommandation officielle de l'équipe Qwen-Image-2.1). Ne l'augmentez que si vous utilisez un prompt négatif spécifique.
- **Steps** : 25 à 40 étapes avec le sampler Euler.
- **Résolution (ResolutionSelector)** :
  - Par défaut : 1024x1024 (1 MP)
  - Support natif 2K : 2048x2048 (4 MP en ratio 1:1)

### Génération d'images avec fond transparent (RGBA)
Qwen-Image-2.1 supporte nativement la transparence. Entourez votre prompt ainsi :
```text
This is an RGBA format image with transparency. [Votre sujet ici]. The image has an alpha channel and a transparent background.
```
Et enregistrez au format PNG.

---

## 📁 Organisation des dossiers & Stockage

Pour préserver l'espace disque de la partition `/home`, les données volumineuses sont stockées sur `/mnt/storage` et liées via des liens symboliques :
- [`models/`](file:///home/abdennebi/Repos/ComfyProject/models) -> `/mnt/storage/comfyui/models`
- [`output/`](file:///home/abdennebi/Repos/ComfyProject/output) -> `/mnt/storage/comfyui/output` (vos images générées)
- [`custom_nodes/`](file:///home/abdennebi/Repos/ComfyProject/custom_nodes) -> `/mnt/storage/comfyui/custom_nodes` (**ComfyUI-Manager** est inclus)
- [`workflows/`](file:///home/abdennebi/Repos/ComfyProject/workflows) -> Workflows prédéfinis (Text-to-Image et Image Edit)

---

## 🛠 Commandes utiles

- **Voir les logs en direct** :
  ```bash
  docker compose logs -f
  ```
- **Arrêter ComfyUI** :
  ```bash
  ./stop.sh
  # ou :
  docker compose down
  ```
- **Redémarrer ComfyUI** :
  ```bash
  docker compose restart
  ```
