class ARModel {
  final String name;
  final String url;
  final String icon;
  final String description;

  ARModel({
    required this.name,
    required this.url,
    required this.icon,
    required this.description,
  });
}

final List<ARModel> arModels = [
  ARModel(
    name: "Astronauta",
    url: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
    icon: "👨‍🚀",
    description: "Astronauta espacial 3D",
  ),
  ARModel(
    name: "Robot Expresivo",
    url: "https://modelviewer.dev/shared-assets/models/RobotExpressive.glb",
    icon: "🤖",
    description: "Robot animado con expresiones",
  ),
  ARModel(
    name: "VR Helmet",
    url: "https://modelviewer.dev/shared-assets/models/DamagedHelmet.glb",
    icon: "🪖",
    description: "Casco de realidad virtual",
  ),
  ARModel(
    name: "Shoe",
    url: "https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb",
    icon: "👟",
    description: "Zapato de Neil Armstrong",
  ),
];
