<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="<?php echo e(csrf_token()); ?>">

    <?php if (isset($component)) { $__componentOriginal103f614934efd83207b28be25fed64f6 = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal103f614934efd83207b28be25fed64f6 = $attributes; } ?>
<?php $component = Illuminate\View\AnonymousComponent::resolve(['view' => 'components.pwa-head','data' => []] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('pwa-head'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\Illuminate\View\AnonymousComponent::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes([]); ?>
<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal103f614934efd83207b28be25fed64f6)): ?>
<?php $attributes = $__attributesOriginal103f614934efd83207b28be25fed64f6; ?>
<?php unset($__attributesOriginal103f614934efd83207b28be25fed64f6); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal103f614934efd83207b28be25fed64f6)): ?>
<?php $component = $__componentOriginal103f614934efd83207b28be25fed64f6; ?>
<?php unset($__componentOriginal103f614934efd83207b28be25fed64f6); ?>
<?php endif; ?>

    <?php echo app('Illuminate\Foundation\Vite')(['resources/css/app.css', 'resources/js/app.js', "resources/js/Pages/{$page['component']}.vue"]); ?>
    <?php if (!isset($__inertiaSsrDispatched)) { $__inertiaSsrDispatched = true; $__inertiaSsrResponse = app(\Inertia\Ssr\Gateway::class)->dispatch($page); }  if ($__inertiaSsrResponse) { echo $__inertiaSsrResponse->head; } ?>
</head>
<body class="antialiased">
    <?php if (!isset($__inertiaSsrDispatched)) { $__inertiaSsrDispatched = true; $__inertiaSsrResponse = app(\Inertia\Ssr\Gateway::class)->dispatch($page); }  if ($__inertiaSsrResponse) { echo $__inertiaSsrResponse->body; } else { ?><div id="app" data-page="<?php echo e(json_encode($page)); ?>"></div><?php } ?>

    <?php if (isset($component)) { $__componentOriginalf300c3ec61ffafbb85be89faef321ec9 = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginalf300c3ec61ffafbb85be89faef321ec9 = $attributes; } ?>
<?php $component = Illuminate\View\AnonymousComponent::resolve(['view' => 'components.pwa-register','data' => []] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('pwa-register'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\Illuminate\View\AnonymousComponent::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes([]); ?>
<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginalf300c3ec61ffafbb85be89faef321ec9)): ?>
<?php $attributes = $__attributesOriginalf300c3ec61ffafbb85be89faef321ec9; ?>
<?php unset($__attributesOriginalf300c3ec61ffafbb85be89faef321ec9); ?>
<?php endif; ?>
<?php if (isset($__componentOriginalf300c3ec61ffafbb85be89faef321ec9)): ?>
<?php $component = $__componentOriginalf300c3ec61ffafbb85be89faef321ec9; ?>
<?php unset($__componentOriginalf300c3ec61ffafbb85be89faef321ec9); ?>
<?php endif; ?>
</body>
</html>
<?php /**PATH C:\Users\lapto\Documents\Akram\Project UKK\Ekspedisii_fixed_total\resources\views/app.blade.php ENDPATH**/ ?>