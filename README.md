# ComfyUI - Qwen-Image-2.1 (Multi-Hardware Docker)

Ce projet permet d'exécuter **ComfyUI** avec le modèle **Qwen-Image-2.1** de manière entièrement autonome, portable et prête à l'emploi.

Il intègre des **profils matériels pré-configurés** pour s'adapter automatiquement aux spécificités architecturales de votre GPU :
* 💻 **NVIDIA GeForce RTX 3070** (x86_64, 8 Go VRAM dédiée GDDR6)
* 🚀 **NVIDIA Jetson AGX Orin 32GB** (ARM64 / aarch64, 32 Go Mémoire Unifiée LPDDR5)

---

## 🎯 Comparatif des Profils Matériels

| Spécification | Profil RTX 3070 (`rtx3070`) | Profil Jetson AGX Orin (`jetson`) |
| :--- | :--- | :--- |
| **Architecture** | `x86_64` (PC / Serveur standard) | `aarch64` / ARM64 (JetPack 6.x) |
| **Mémoire** | 8 Go VRAM GDDR6 dédiée | 32 Go Mémoire Unifiée (UMA - CPU & GPU partagés) |
| **Gestion mémoire ComfyUI** | `--reserve-vram 2.5 --lowvram --fp16-vae` | `--highvram --reserve-vram 4.0 --fp16-vae` |
| **Stratégie d'offloading** | Déchargement agressif des poids en RAM système | Poids résidents en mémoire (~16 Go pour INT8 DiT + CLIP + VAE) |
| **Résolution conseillée** | 1.0 Mégapixel (1024x1024) | 1024x1024 jusqu'à 2048x2048 (2K) |
| **Image Docker de base** | `nvidia/cuda:12.4.1-devel-ubuntu22.04` | `dustynv/comfyui:r36.4.0` (Jetson Tegra SM 8.7) |
| **Runtime Docker** | Standard NVIDIA Container Toolkit | `runtime: nvidia` |

---

## 🚀 Démarrage Rapide

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

#### Option A : Détection automatique (recommandé)
Le script détecte l'architecture du processeur (`x86_64` vs `aarch64`) et lance le bon profil :
```bash
./start.sh
```

#### Option B : Spécifier le profil explicitement
* Pour la **RTX 3070** :
  ```bash
  ./start.sh 3070
  # ou : docker compose --profile rtx3070 up -d
  ```
* Pour la **Jetson AGX Orin 32GB** :
  ```bash
  ./start.sh jetson
  # ou : docker compose --profile jetson up -d
  ```

Ouvrez ensuite votre navigateur sur :
👉 **http://localhost:8188** (ou `http://<IP-DE-VOTRE-MACHINE>:8188`)

---

## ⚙️ Configuration & Profils (`profiles/`)

Deux fichiers de configuration prêts à l'emploi sont disponibles dans `profiles/` :
* `profiles/rtx3070.env`
* `profiles/jetson-orin.env`

Pour appliquer manuellement un profil ou personnaliser les dossiers :
```bash
# Exemple pour RTX 3070 :
cp profiles/rtx3070.env .env

# Exemple pour Jetson AGX Orin :
cp profiles/jetson-orin.env .env
```

### Variables principales du fichier `.env` :

| Variable | Description | Défaut |
| :--- | :--- | :--- |
| `COMPOSE_PROFILES` | Profil actif (`rtx3070` ou `jetson`) | Auto-détecté par `start.sh` |
| `STORAGE_DIR` | Emplacement hôte pour les modèles, sorties et custom_nodes | `./data` |
| `PORT` | Port d'écoute du serveur web ComfyUI | `8188` |
| `CLI_ARGS` | Arguments d'optimisation mémoire pour ComfyUI | Dépend du profil |
| `JETPACK_TAG` | Tag L4T pour Jetson (ex: `r36.4.0` pour JetPack 6.1/6.2) | `r36.4.0` |

---

## 🎨 Utilisation & Workflows

Les templates de workflows pour Qwen-Image-2.1 sont injectés automatiquement dans ComfyUI :
1. Dans l'interface web ComfyUI, cliquez sur **Workflow > Open** (ou le panneau latéral **Load**).
2. Sélectionnez **`Qwen_Image_2_1_t2i`** (Génération Text-to-Image) ou **`Qwen_Image_2_1_image_edit`** (Édition d'image).
3. Saisissez votre prompt dans le nœud `Text Encode Qwen Image 2.1`.
4. Cliquez sur **Queue Prompt** (ou `Ctrl + Entrée`).

### Paramètres recommandés :
* **CFG** : Laisser à **1** (recommandation officielle de l'équipe Qwen).
* **Sampler / Steps** : `euler` avec 25 à 40 étapes.
* **Transparence (RGBA)** : Si vous voulez générer un PNG avec fond transparent :
  `This is an RGBA format image with transparency. [Votre sujet]. The image has an alpha channel and a transparent background.`

---

## 🛠 Commandes utiles

* **Démarrer** : `./start.sh` (ou `./start.sh 3070` / `./start.sh jetson`)
* **Arrêter** : `./stop.sh`
* **Voir les logs** : `docker compose logs -f`
* **Gestionnaire de nœuds** : Cliquez sur le bouton **Manager** intégré dans la barre d'outils de ComfyUI.
