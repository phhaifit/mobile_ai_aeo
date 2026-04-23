## Project structure

```bash
    ├── README.md                       # README file
    ├── .github                         # GitHub folder
    │   └── workflows                   # GitHub Actions workflows
    ├── prisma                          # Prisma folder
    │   ├── migrations                  # Prisma migrations
    │   └── schema.prisma               # Prisma schema file
    ├── src
    │   ├── prisma                      # Prisma related files
    │   │   ├── prisma.module.ts        # Prisma module
    │   │   └── prisma.service.ts       # Prisma service
    │   ├── users                       # Users module
    │   │   ├── dto                     # Data Transfer Objects for users
    │   │   ├── entities                # User entities
    │   │   ├── users.controller.ts     # Users controller
    │   │   ├── users.module.ts         # Users module
    │   │   └── users.service.ts        # Users service
    │   ├── app.module.ts               # Main application module
    │   └── main.ts                     # Main application entry point
    ├── tests
    │   ├── e2e                         # E2E tests, also includes Monitoring as Code (not implemented yet)
    │   └── integration                 # Integration tests (not implemented yet)
    ├── .prettierrc.json                # Prettier configuration
    ├── .eslint.config.js               # ESLint configuration
    ├── .env                            # Local environment variables
    └── tsconfig.json                   # TypeScript configuration
```

Reference: [NestJs Boilerplate](https://github.com/brocoders/nestjs-boilerplate)

## Project setup

```bash
    $ pnpm install
```

## Compile and run the project

```bash
    # development
    $ pnpm run start

    # watch mode
    $ pnpm run start:dev

    # production mode
    $ pnpm run start:prod
```

## Run tests

```bash
  # unit tests
    $ pnpm run test

    # e2e tests
    $ pnpm run test:e2e

    # test coverage
    $ pnpm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
    $ pnpm install -g @nestjs/mau
    $ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.
