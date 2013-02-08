module brala.entities.player;

private {
    import glwtf.window : Window;

    import core.time : TickDuration;
    
    import brala.game : BraLaGame;
    import brala.engine : BraLaEngine;
    import brala.network.session : Session;
    import brala.network.connection : Connection;
    import brala.entities.mobs : NamedEntity;
}

class Player : NamedEntity {
    BraLaGame game;
    BraLaEngine engine;
    Window window;
    Connection connection;

    @property auto world() {
        return game.current_world;
    }

    this(BraLaGame game, int entity_id) {
        this.game = game;
        this.engine = game.engine;
        this.window = engine.window;
        this.connection = game.connection;
        
        super(entity_id, game.session.minecraft_username);
    }

    void update(TickDuration delta_t) {
    }
}