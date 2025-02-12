enum Env { dev, prod }

class EnvConfig {
  static final Map<Env, SupabaseConfigModel> config = {
    Env.dev: SupabaseConfigModel(
      isdev: true,
      supabaseUrl: 'https://hnyyuaeeasyhuytscoxk.supabase.co',
      supabaseAnon:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhueXl1YWVlYXN5aHV5dHNjb3hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgwNDA4NzgsImV4cCI6MjA1MzYxNjg3OH0.S5r0Fcgwz6np-ymQLx9QaV0uKCeUFUG6OSQTje0Ysr0',
    ),
    Env.prod: SupabaseConfigModel(
      isdev: false,
      supabaseUrl: '',
      supabaseAnon: '',
    )
  };

  static SupabaseConfigModel getCurrentENV(Env env) => config[env]!;
}

class SupabaseConfigModel {
  final String supabaseUrl;
  final String supabaseAnon;
  final bool isdev;

  const SupabaseConfigModel({
    required this.supabaseUrl,
    required this.isdev,
    required this.supabaseAnon,
  });
}
